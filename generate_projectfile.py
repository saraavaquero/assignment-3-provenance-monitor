import os
import json
import random
import uuid
from datetime import datetime, timedelta

# Create the folder where the JSON files will be stored
folder_path = "project_files/json_logs"
os.makedirs(folder_path, exist_ok=True)

# Simple random values
nodes = ["cresselia", "darkrai", "lugia"]
users = ["salle_alumni", "bioinfo_user", "student"]
categories = ["Genet", "Clinical", "Research"]

# Create 100 JSON files
for i in range(1, 101):

    sample = f"3D_{100 + i}_S{i}"

    start = datetime(2026, 3, 31, 10, 0, 0) + timedelta(minutes=random.randint(1, 500))
    end = start + timedelta(seconds=random.randint(120, 900))

    sha_result = random.choice(["La suma coincide", "ERROR checksum mismatch"])
    seqfu_result = random.choice(["OK PE", "ERROR FASTQ integrity check failed"])

    record = {
        "@context": "http://www.w3.org/ns/prov#",
        "@id": "urn:uuid:" + str(uuid.uuid4()),
        "@type": "Activity",
        "label": "Processament complet de " + sample,
        "startTime": start.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "endTime": end.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "executionNode": random.choice(nodes),
        "sourceDirectory": "/data/input/",
        "destinationDirectory": "/data/output/" + sample,

        "wasAssociatedWith": [
            {
                "@type": "SoftwareAgent",
                "label": "seqfu",
                "version": "1.22.3"
            },
            {
                "@type": "SoftwareAgent",
                "label": "sha256sum",
                "version": "sha256sum (GNU coreutils) 8.32"
            },
            {
                "@type": "SoftwareAgent",
                "label": "Pipeline Nextflow fastq_prov",
                "repository": "local",
                "commitId": "N/A",
                "revision": "N/A"
            },
            {
                "@id": "urn:person:" + random.choice(users),
                "@type": "Person",
                "label": "Usuari executor: " + random.choice(users),
                "actedOnBehalfOf": {
                    "@id": "https://ror.org/01y990p52",
                    "@type": "Organization",
                    "label": "La Salle"
                }
            }
        ],

        "generated": [
            {
                "@type": "Entity",
                "label": "Verificació SHA256",
                "description": "Resultat de la comprovació de checksum a destí",
                "value": sample + "_R1_001.fastq.gz: " + sha_result
            },
            {
                "@type": "Entity",
                "label": "Verificació Seqfu",
                "description": "Resultat de la comprovació d'integritat del format FASTQ",
                "value": seqfu_result + " " + sample + "_R1_001.fastq.gz"
            },
            {
                "@type": "Entity",
                "label": "FASTQ Files",
                "totalSizeBytes": str(random.randint(800000000, 8000000000)),
                "category": random.choice(categories),
                "fileCount": "2"
            }
        ]
    }

    file_name = f"{folder_path}/provenance_log_{i}.json"

    with open(file_name, "w", encoding="utf-8") as file:
        json.dump(record, file, indent=2, ensure_ascii=False)

print("100 JSON files created successfully.")
print("Folder:", folder_path)