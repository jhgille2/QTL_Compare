## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  
  # Input files
  # 1. QTL found in pops 33 and 34
  # 2. Past QTL with literature/other data
  # 3. Conversion table between LG names and numbers
  # 4. Consensus map with physical/genetic positions
  tar_target(Pop33_34_QTL, 
             here("data", "qtl_tables.xlsx"), 
             format = "file"), 
  
  tar_target(LiteratureTable, 
             here("data", "ProtOilYieldLit.csv"), 
             format = "file"), 
  
  tar_target(QTL_Name_Conversion, 
             "https://raw.githubusercontent.com/jhgille2/SoybaseData/master/SoybaseLGAssignments.csv", 
             format = "url"),
  
  tar_target(ConsensusMap, 
             "https://raw.githubusercontent.com/jhgille2/SoybaseData/master/ConsensusMapWithPositions.csv", 
             format = "url"),
  
  # Read in the files
  tar_target(ReadData, 
             read_all_data(newQTL = Pop33_34_QTL, 
                           oldQTL = LiteratureTable, 
                           conversionTable = QTL_Name_Conversion, 
                           consensus = ConsensusMap)),
  
  # Add Consensus map marker positions to the new QTL data
  tar_target(Clean_New_QTL, 
             clean_NewData(qtlData = ReadData$NewQTL, 
                           ConsensusData = ReadData$Consensus)), 
  
  # Join with the literature table to find which past QTL
  # have been found in similar regions
  tar_target(LiteratureMerge, 
             add_past_literature(LiteratureData = ReadData$OldQTL, 
                                 NewQTL = Clean_New_QTL, 
                                 buffer = 5)),
  
  # Write the merged file
  tar_target(SaveMergedFile, 
             save_merged(data = LiteratureMerge, dest = here("data", "LiteratureAdded.csv")), 
             format = "file"),
  
  # Render the summary write up
  tar_render(Writeup, "docs/Writeup.Rmd")
)
