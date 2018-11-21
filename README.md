  # Orchestrator
  ## Binary already compiled

  ### Build Image
  docker build -t orchestrator:latest .

  ### Run Container
  docker run --rm --name orchestrator -p 3000:3000 orchestrator:latest
