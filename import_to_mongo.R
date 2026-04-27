library(jsonlite)
library(mongolite)

# Folder with JSON files
folder_path <- "project_files/json_logs"

# Get all JSON file paths
json_files <- list.files(
  path = folder_path,
  pattern = "\\.json$",
  full.names = TRUE
)

# Read JSON files as raw text (preserves nested structure)
records_json <- sapply(json_files, function(file) {
  paste(readLines(file, warn = FALSE), collapse = "\n")
})

# Connect to MongoDB
mongo_db <- mongo(
  collection = "provenance_logs",
  db = "genomic_provenance_db",
  url = "mongodb://localhost:27017"
)

# Clean collection (optional but recommended)
mongo_db$remove("{}")

# Insert each JSON into MongoDB
for (record in records_json) {
  mongo_db$insert(record)
}

# Final message
cat(length(records_json), "JSON files imported into MongoDB successfully.\n")