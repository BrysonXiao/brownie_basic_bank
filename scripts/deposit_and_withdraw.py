from brownie import BasicBank
from scripts.utilities import get_account

def deposit():
    basic_bank = BasicBank[-1]
    account = get_account()
    entrance_fee = basic_bank.getEntranceFee()
    print(f'The current entry fee is {entrance_fee}')
    print('Depositing entry fee...')
    basic_bank.deposit({'from': account, 'value': entrance_fee})
    print('Deposited')

def withdraw():
    basic_bank = BasicBank[-1]
    account = get_account()
    entrance_fee = basic_bank.getEntranceFee()
    print(f'The current entry fee is {entrance_fee}')
    print('Withdrawing entry fee...')
    basic_bank.withdraw(entrance_fee, {'from': account})
    print('Withdrew')

# $50 = 0.025000000000000000 eth in mock
def main():
    deposit()
    withdraw()
