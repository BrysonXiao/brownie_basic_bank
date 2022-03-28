from brownie import network, accounts, exceptions
import pytest
from scripts.utilities import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_basic_bank

def test_can_deposit_and_withdraw():
    account = get_account()
    basic_bank = deploy_basic_bank()
    entrance_fee = basic_bank.getEntranceFee()

    # Testing depositing
    txn = basic_bank.deposit({'from': account, 'value': entrance_fee + 100})
    txn.wait(1)
    assert basic_bank.addressToBalance(account.address) == entrance_fee + 100

    # Testing withdrawing
    txn2 = basic_bank.withdraw(entrance_fee, {'from': account})
    txn.wait(1)
    assert basic_bank.addressToBalance(account.address) == 100

def test_only_owner_can_change_min():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip('only for local testing')
    basic_bank = deploy_basic_bank()
    bad_actor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        basic_bank.setMinDeposit(100, {'from': bad_actor})