from brownie import BasicBank, MockV3Aggregator, network, config
from scripts.utilities import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS

def deploy_basic_bank():
    account = get_account()
    # Need to pass the price feed address to the BasicBank contract now
    # if we are on a persistent network like rinkeby, use the associated address
    # otherwise, deploy mocks

    '''
    Note: When using local ganache chain, the contracts will be deleted after the instance is closed. 
    Should try deleting the contracts from chain id 1337 folder and map.json
    '''
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config['networks'][network.show_active()]['eth_usd_price_feed']
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address
    basic_bank = BasicBank.deploy(
        price_feed_address, 
        {'from': account}, 
        publish_source=config['networks'][network.show_active()].get('verify'),
    )
    print(f'Contract deployed to {basic_bank.address}')

    return basic_bank

def main():
    deploy_basic_bank()
