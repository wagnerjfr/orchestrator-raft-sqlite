  #Orchestrator

  ###Build
  docker build -t orchestrator:latest .

  ##Run
  docker run --rm --name orchestrator -p 3000:3000 orchestrator:latest
