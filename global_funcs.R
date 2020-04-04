secrets <- read.csv(".secrets.csv", stringsAsFactors = F)

client_id <- secrets$client_id
client_secret <- secrets$client_secret
auth_file <- secrets$authfile
Sys.setenv("GCS_DEFAULT_BUCKET" = client_id,
           "GCS_AUTH_FILE" = auth_file)

for(p in c("conflicted", "tidyverse", "lubridate", "magrittr", "Rcpp", "shiny", "shinyjs", "audio", "reticulate", "httr", "tuber", "googleCloudStorageR", "zipangu", "stringdist")){
  if(!p %in% installed.packages())  install.packages(p)
  require(p, character.only = T)
}
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

if(!"googleLanguageR" %in% installed.packages()) remotes::install_github("ropensci/googleLanguageR")
require(googleLanguageR)
if(!"tubeplayR" %in% installed.packages()) remotes::install_github("kazutan/tubeplayR")
require(tubeplayR)

py_discover_config()
py_config()

# YouTube API authorization 
if(!file.exists(".httr-oauth")) {
  yt_oauth(app_id = client_id, app_secret = client_secret)
} else {
  yt_oauth()
}



# Goolge Language API autholization
gl_auth("tubeapi-test-8eb3206fdbe0.json")
# Google Cloud Storage
# TODO: ストレージ作成
# TODO: uniform bucket-level acces の場合はuploadできない?
gcs_global_bucket("tubeapi-test-storage")
gcs_get_global_bucket()


get_video_duration <- function(id){
  details <- get_video_details(video_id = id, part = "contentDetails")
  details$items[[1]]$contentDetails$duration %>% str_remove("^PT") %>% as.period %>% as.numeric
}

get_youtube_id <- function(str){
  if(grepl("playlist?", str)) {
    # set target for list
    str <- gsub("^.*\\.com/", "", str)
    str <- gsub("playlist", "videoseries", target)
  }
  else if(grepl("^https://www.youtube.com/", str)){
    # set target for single
    str <- gsub("^.*\\?v=", "", str)
    str <- gsub("\\&.*$", "", str)
  }
  return(str)
}

record_voice <- function(seconds, file = NULL, Hz = 44100){
  if(is.null(file)){
    file <- paste0(tempfile(), ".flac")
  }
  wavfile <- tempfile()
  # TODO: ffmpeg or flac?
  r <- system(paste("python record.py", as.integer(seconds), wavfile, "&& ffmpeg -y -i", wavfile, "-c:a flac -ar", Hz, file))
  return(file)
}

get_gl_speech <- function(file, lang = "ja-JP", Hz = 44100){
  gcs_upload(file = file, name = "tmp.flac")
  r <- gl_speech("gs://tubeapi-test-storage/tmp.flac", encoding = "FLAC", languageCode = lang, sampleRateHertz = Hz, asynch = T)
  # TODO: better way
  while(class(r) == "gl_speech_op"){
    Sys.sleep(4)
    r <- gl_speech_op(r)
  }
  return(r)
}

convert_gl_speech_yomi <- function(x){
  splitted <- str_split(x, "\\|", simplify = T) %>% as.character
  if(length(splitted) >= 2){
    return(str_split(splitted[2], ",", simplify = T) %>% .[1])
  } else {
    return(str_conv_hirakana(splitted, "katakana"))
  }
}

get_voice_text_gls <- function(gcs_output){
  gcs_output$timing %>% bind_rows %>% as_tibble %>%
    mutate(
      start_voice = period(startTime), end_voice = period(endTime),
      voice = map_chr(word, ~convert_gl_speech_yomi(.x)),
      index_voice = row_number()
    )
}

get_video_caption <- function(video_id, lang = "ja"){
  tracks <- list_caption_tracks(part = "snippet", video_id = video_id, lang = lang)
  caption_id <- arrange(
    filter(mutate(tracks, lastUpdated = as.POSIXct(lastUpdated)),
           language == lang), lastUpdated
  )$id %>% as.character
  captions <- get_captions(id = caption_id, lang = lang) %>%
    as.character %>% strtoi(16L) %>% as.raw %>% rawToChar
  str_split(captions, pattern="\\n\\n")[[1]] %>% str_split(pattern = "\\n") %>%
    map_dfr(~(tibble(text = list(.x[-1])) %>% bind_cols(as_tibble(str_split(.x[1], ",", simplify = T),
                                                                  .name_repair = "minimal")))
    ) %>%
    filter(!(is.na(V1) | is.na(V2) | V1 == "" | V2 == "")) %>%
    mutate(start = hms(V1), end = hms(V2), index_lyrics = row_number()) %>% select(index_lyrics, start, end, text)
}

coalesce_kana <- function(characters, rm.blank = TRUE){
  characters <- c(characters[str_detect(characters, pattern = "\\p{Katakana}")], "")
  coalesce(!!!characters)
}

# TODO: もっとスマートな方法?
# TODO: 日本語以外の非表音文字の変換
convert_pronounce <- function(data, lang = "ja"){
  if(lang == "ja"){
    fname <- tempfile()
    data  %>% mutate(text_unnest = map_chr(text, ~paste(.x, collapse = ""))) %>%
      select(text_unnest) %>% write_csv(path = fname, col_names = F)
    data <- data %>%
      mutate(pronounce = system(paste("mecab -Oyomi -r .mecabrc", fname), intern = T) %>%
               str_remove_all(pattern = "[^\\p{Katakana}ー]"))
  } else{
    data %>% mutate(pronounce = map_chr(text, ~paste(.x, collapse = "")))
  }
  return(data)
}

# スコア計算
join_lyrics_voice <- function(lyrics, voice, tol_delay = .7){
  coord_indices <- lyrics %>% select(start, end, index_lyrics) %>% mutate(idx = T) %>%
    left_join(., select(voice, index_voice, start_voice, end_voice) %>% mutate(idx = T), by = "idx") %>%
    mutate(distance = abs(start - start_voice)) %>%
    filter(distance <= tol_delay) %>% arrange(index_lyrics, distance) %>%  group_by(index_lyrics) %>% summarise(index_voice = first(index_voice))
  voice_matched <- voice %>% left_join(coord_indices, by = "index_voice") %>%
    fill(index_lyrics, .direction = "down") %>%
    group_by(index_lyrics) %>% summarise(voice = paste0(voice, collapse = ""))
  lyrics %>% left_join(voice_matched, by = "index_lyrics") %>%
    mutate(voice = replace_na(voice, ""))
}

compute_karaoke_score <- function(lyrics_voice = .7){
  lyrics_voice %>%
    rowwise %>% mutate(sim = max(1 - adist(x = pronounce, voice) %>% as.numeric / str_length(pronounce), 0)) %>% ungroup %>%
    summarise(score = mean(sim) * 100) %>% .$score
}
