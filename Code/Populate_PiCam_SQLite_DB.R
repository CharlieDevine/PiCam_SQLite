library(RSQLite)

# Get directory paths
setwd('../')
git.fp = getwd()
data.fp = paste(git.fp, 'Data', sep = '/')

# Get list of file paths for raw vegetation index output .txt files from Phenopix image processing
vi.files = list.files(paste(data.fp, 'Phenopix_Output_Files', sep = '/'), 
                      pattern = 'Daily_Means', 
                      full.names = TRUE, 
                      recursive = TRUE)

plot.ids = c('H1_P1_W3_S4','H1_P2_W2_S2','H1_P3_W3_S1','H1_P4_W1_S1','H1_P5_W1_S3','H1_P6_W3_S2',
             'H1_P7_W2_S1','H1_P8_W1_S4','H1_P9_W1_S2','H1_P10_W2_S3','H1_P11_W3_S3','H1_P12_W2_S4',
             'H2_P1_W1_S3','H2_P2_W2_S2','H2_P3_W2_S3','H2_P4_W1_S1','H2_P5_W2_S1','H2_P6_W3_S4',
             'H2_P7_W1_S4','H2_P8_W1_S2','H2_P9_W3_S1','H2_P10_W3_S3','H2_P11_W3_S2','H2_P12_W2_S4',
             'H3_P1_W1_S2','H3_P2_W3_S3','H3_P3_W1_S4','H3_P4_W3_S1','H3_P5_W3_S2','H3_P6_W2_S4',
             'H3_P7_W3_S4','H3_P8_W1_S3','H3_P9_W2_S2','H3_P10_W2_S3','H3_P11_W1_S1','H3_P12_W2_S1',
             'H4_P1_W3_S1','H4_P2_W2_S3','H4_P3_W2_S2','H4_P4_W1_S4','H4_P5_W3_S3','H4_P6_W1_S2',
             'H4_P7_W2_S4','H4_P8_W2_S1','H4_P9_W3_S2','H4_P10_W1_S1','H4_P11_W3_S4','H4_P12_W1_S3',
             'H5_P1_W2_S3','H5_P2_W3_S4','H5_P3_W2_S4','H5_P4_W3_S2','H5_P5_W3_S3','H5_P6_W1_S2',
             'H5_P7_W1_S4','H5_P8_W1_S1','H5_P9_W2_S2','H5_P10_W2_S1','H5_P11_W1_S3','H5_P12_W3_S1')

# Create function to loop through each PiCam VI output file and append it to the existing "PiCam_Summer2020.db" SQLite database
update.picam.sqlite.db = function(){
  
  # Connect to "PiCam_Summer2020.db" SQLite database
  picam.db = dbConnect(RSQLite::SQLite(), paste(data.fp, 'PiCam_Summer2020.db', sep = '/'))
  
  for (i in 1 : length(vi.files)){
    
    # Read individual plot VI output files
    picam.df = read.table(vi.files[i], header = TRUE)
    
    # Extract plot info from plot naming convention
    # e.g. HouseID _ Plot Number _ Winter Treatment _ Summer Treatment
    plot.info = unlist(strsplit(plot.ids[i], split = '_'))
    
    print(paste0('Updating plot ', plot.ids[i], ' (', i, ' out of ', length(plot.ids),')'))
    
    # ~~~~~~~~~ Populate PiCam data frame with plot info
    # HouseID
    if (plot.info[1] == 'H1') {
      picam.df$HouseID = 'House01'
    }
    if (plot.info[1] == 'H2') {
      picam.df$HouseID = 'House02'
    }
    if (plot.info[1] == 'H3') {
      picam.df$HouseID = 'House03'
    }
    if (plot.info[1] == 'H4') {
      picam.df$HouseID = 'House04'
    }
    if (plot.info[1] == 'H5') {
      picam.df$HouseID = 'House05'
    }
    
    # Plot number (w/ leading zero if plot number is <10)
    picam.df$Plot = sprintf('%02d', as.numeric(gsub('P','',plot.info[2])))
    
    # Winter treatment
    picam.df$Winter = plot.info[3]
    
    # Summer treatment
    picam.df$Summer = plot.info[4]
    
    # Write PiCam data frame (updated w/ plot info) to "PiCam_Summer2020.db" SQLite database
    dbWriteTable(conn = picam.db, 
                 name = 'PiCam_VI_Outputs', 
                 value = picam.df, 
                 header = TRUE,
                 append = TRUE)
  }
  
  # Disconnect from 'PiCam_Summer2020.db'
  dbDisconnect(picam.db)
}

# Run function
update.picam.sqlite.db()


# testq = dbGetQuery(picam.db, 
#                    statement = "SELECT Dates_YYYYMMDD, HouseID, Plot, Winter, Summer, Green_Index_av 
#                                 FROM PiCam_VI_Outputs
#                                 WHERE HouseID = 'House05' 
#                                   AND Plot = '01' 
#                                 ORDER BY Dates_YYYYMMDD DESC " )