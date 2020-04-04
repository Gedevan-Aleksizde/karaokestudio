source(file = "global_funcs.R", encoding = "utf-8", local = T)

video_id <- "XSLhsjepelI" # miku
video_id <- "iH_YJde1yps" # dorohedoro
lang = "ja-JP"
lyrics <- read_rds("test_lyrics_dorohedoro.rds")

ui <- fluidPage(
  useShinyjs(),
  titlePanel(
    fluidRow(
      column(width = 3, "KaʀaokeStudio"),
      column(width = 9, img(src = "icon.svg", height = 80, width = 80), align = "right"),
      id = "title-header"
    ),
    windowTitle = "KaʀaokeStudio"
  ),
  h3(strong("タイトル:"), get_video_details(video_id)$items[[1]]$snippet$title),
  sidebarLayout(
    sidebarPanel(
      div(
        div(
          # div(htmlOutput("out1")),
          textInput(inputId = "videoId", label = "video ID", value = video_id)
          ), id = "sidebar-panel"
        ),
      width = 2
    ),
    mainPanel(
      div(id = "player", frameborder = "0"),
      tags$script(HTML(paste("var video_id =", sQuote(video_id, F), ";")),
                  HTML(read_file("js/youtube_api.js"))),
      id = "video-panel",
      width = 9
      )
  ), theme = "css/karaokestudio.css"
)

server <- function(input, output, session){
  observeEvent(input$videoStatus,
               {
                 if(input$videoStatus == 1){
                   duration <- get_video_duration(id = video_id)
                   fpath <- record_voice(file = "tmp_shinytest.flac", seconds = duration)
                   print("recoding converted")
                   showNotification("scoring started...", type = "message")
                   voice <- get_voice_text_gls(get_gl_speech(fpath, lang = lang))
                   print("voice recognized")
                   if(is.null(lyrics)){
                     lyrics <- convert_pronounce(get_video_caption(video_id = video_id))
                   }
                   print("lyrics downloaded")
                   score <- compute_karaoke_score(join_lyrics_voice(lyrics, voice))
                   print(score)
                   showNotification(
                     paste("SCORE: ", round(score), "/ 100"), type = "message", closeButton = T, duration = NULL
                     )
                 }
               })
  observeEvent(input$do, {
    showNotification(p("test"),
                     type = "message", closeButton = T, duration = NULL)
  })
  # output$out1 <- renderText(input$videoStatus)
}

shinyApp(ui = ui, server = server)