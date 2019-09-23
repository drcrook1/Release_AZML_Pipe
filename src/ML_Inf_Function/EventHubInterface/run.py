"""
Author: David Crook
Email: DaCrook@Microsoft.com
"""
import os
import requests
import logging

def pipeEndpoint():
    return os.environ['MLPipeHttpEndpoint']

def run(event_json):
    logging.error("I Don't Do Anything Yet!")
