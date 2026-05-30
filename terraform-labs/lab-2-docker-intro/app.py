#!/usr/bin/env python3
"""
Lab 2: Docker Introduction
Simple Flask web application for learning Docker concepts
"""

from flask import Flask, jsonify
import os
from datetime import datetime

app = Flask(__name__)

# Configuration from environment variables
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
VERSION = os.getenv("APP_VERSION", "1.0.0")
PORT = int(os.getenv("PORT", 5000))


@app.route("/", methods=["GET"])
def home():
    """Home endpoint"""
    return jsonify({
        "message": "Lab 2: Docker Introduction",
        "status": "running",
        "environment": ENVIRONMENT,
        "version": VERSION,
        "timestamp": datetime.utcnow().isoformat()
    })


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200


@app.route("/info", methods=["GET"])
def info():
    """Application information"""
    return jsonify({
        "app": "terraform-labs-app",
        "lab": 2,
        "name": "Docker Introduction",
        "version": VERSION,
        "environment": ENVIRONMENT,
        "features": [
            "Docker containerization",
            "Health checks",
            "Environment variables",
            "Multi-stage builds",
            "Docker Compose"
        ]
    })


@app.route("/echo/<message>", methods=["GET"])
def echo(message):
    """Echo endpoint to test request handling"""
    return jsonify({
        "message": message,
        "echo": message,
        "timestamp": datetime.utcnow().isoformat()
    })


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({"error": "Not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({"error": "Internal server error"}), 500


if __name__ == "__main__":
    print(f"Starting Lab 2 app - Environment: {ENVIRONMENT}, Version: {VERSION}")
    app.run(host="0.0.0.0", port=PORT, debug=(ENVIRONMENT == "development"))
