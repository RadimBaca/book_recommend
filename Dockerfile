FROM python:3.9-slim

# Set the working directory
WORKDIR /app

COPY . .

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    make \
    gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install -r requirements.txt
RUN npm --prefix reports install

# Install make
RUN apt-get update && \
    apt-get install -y make && \
    rm -rf /var/lib/apt/lists/*

# Run the Makefile targets
RUN make download
RUN make dbt-run
RUN make evidence

# Install a simple HTTP server
RUN pip install http.server

# Expose the port for the web server
EXPOSE 8000

# Command to run the local web server
CMD ["python", "-m", "http.server", "8000", "--directory", "reports/build"]