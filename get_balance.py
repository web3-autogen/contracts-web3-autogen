import json
from web3 import Web3
from typing import List, Tuple

def get_safe_info(web3: Web3, safe_address: str, abi: List) -> Tuple[List[str], float]:
    """
    Get the Safe's owners and balance.
    
    Args:
        web3: Initialized Web3 instance
        safe_address: The Safe contract address
        abi: The Safe contract ABI
    
    Returns:
        Tuple[List[str], float]: List of owner addresses and balance in ETH
    """
    # Validate address and contract existence
    safe_address = Web3.to_checksum_address(safe_address)
    code = web3.eth.get_code(safe_address)
    if code == b'' or code == '0x':
        raise ValueError(f"No contract found at address {safe_address}")
    
    # Create contract instance
    safe_contract = web3.eth.contract(address=safe_address, abi=abi)
    
    # Get owners
    owners = safe_contract.functions.getOwners().call()
    
    # Get balance in ETH
    balance_wei = web3.eth.get_balance(safe_address)
    balance_eth = web3.from_wei(balance_wei, 'ether')
    
    return owners, float(balance_eth)

def setup_web3(rpc_url: str) -> Web3:
    """
    Initialize and validate Web3 connection.
    
    Args:
        rpc_url: The RPC endpoint URL
    
    Returns:
        Web3: Initialized Web3 instance
    """
    web3 = Web3(Web3.HTTPProvider(rpc_url))
    if not web3.is_connected():
        raise ConnectionError("Failed to connect to the RPC endpoint")
    return web3

if __name__ == "__main__":
    # Configuration
    RPC_URL = "http://127.0.0.1:8545"
    SAFE_ADDRESS = "0x946Ae7b21de3B0793Bb469e263517481B74A6950"
    SAFE_ABI_PATH = "Safe.json"
    
    try:
        # Setup
        web3 = setup_web3(RPC_URL)
        
        # Load ABI
        with open(SAFE_ABI_PATH, 'r') as f:
            abi = json.load(f)["abi"]
        
        # Get Safe info
        owners, balance = get_safe_info(web3, SAFE_ADDRESS, abi)
        
        # Print results
        print("\nGnosis Safe Info:")
        print("-----------------")
        print(f"Safe Address: {SAFE_ADDRESS}")
        print(f"Balance: {balance:.4f} ETH")
        print("\nOwners:")
        for i, owner in enumerate(owners, 1):
            print(f"{i}. {owner}")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        print("\nDebug Info:")
        try:
            web3 = Web3(Web3.HTTPProvider(RPC_URL))
            print(f"Connected to network: {web3.is_connected()}")
            if web3.is_connected():
                print(f"Chain ID: {web3.eth.chain_id}")
                print(f"Latest block: {web3.eth.block_number}")
        except Exception as debug_e:
            print(f"Debug error: {str(debug_e)}")