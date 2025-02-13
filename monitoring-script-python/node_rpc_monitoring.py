import requests
import time
import logging
import os
from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(
    filename="node_monitoring.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger()

NODE_URL_EXECUTION_LAYER = os.getenv("NODE_URL_EXECUTION_LAYER")
NODE_URL_CONSENSUS_LAYER = os.getenv("NODE_URL_CONSENSUS_LAYER")
INTERVAL = 5


class NodeMonitor:
    def __init__(self, url_execution_layer, url_consensus_layer, interval):
        self.url_execution_layer = url_execution_layer
        self.url_consensus_layer = url_consensus_layer
        self.interval = interval

    def check_health_execution_layer(self):
        try:
            rpc_payload = {"jsonrpc": "2.0", "method": "web3_clientVersion", "params": [], "id": 1}
            res = requests.post(self.url_execution_layer, json=rpc_payload)
            res.raise_for_status()

            execution_layer_version = res.json().get("result")
            logger.info(f"RPC Node Health: ONLINE - execution layer version: {execution_layer_version}")
        except requests.exceptions.RequestException as e:
            logger.error(f"RPC Node Health: OFFLINE execution_layer - Error: {str(e)}")

    def check_health_consensus_layer(self):
        try:
            res = requests.get(f"{self.url_consensus_layer}/node/version" )
            res.raise_for_status()

            consensus_layer_version = res.json().get("data")
            logger.info(f"RPC Node Health: ONLINE - consensus layer version: {consensus_layer_version["version"]}")
        except requests.exceptions.RequestException as e:
            logger.error(f"RPC Node Health: OFFLINE consensus_layer - Error: {str(e)}")

    def monitor(self):
        while True:
            logger.info("Starting health check ...")
            self.check_health_execution_layer()
            self.check_health_consensus_layer()
            logger.info("Monitoring cycle completed. Sleeping...")
            time.sleep(self.interval)


def run_monitor():
    monitor_tool = NodeMonitor(NODE_URL_EXECUTION_LAYER, NODE_URL_CONSENSUS_LAYER, INTERVAL)
    logger.info("Starting RPC Node Monitor")
    monitor_tool.monitor()


if __name__ == "__main__":
    run_monitor()