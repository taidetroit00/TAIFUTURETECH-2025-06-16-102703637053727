import EvmRpc "canister:evm_rpc";
import IC "ic:aaaaa-aa";
import Sha256 "mo:sha2/Sha256";
import Base16 "mo:base16/Base16";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";

persistent actor EvmBlockExplorer {
  transient let key_name = "test_key_1"; // Use "key_1" for production and "dfx_test_key" locally

  public func get_evm_block(height : Nat) : async EvmRpc.Block {
    // Ethereum Mainnet RPC providers
    // Read more here: https://internetcomputer.org/docs/current/developer-docs/multi-chain/ethereum/evm-rpc/overview#supported-json-rpc-providers
    let services : EvmRpc.RpcServices = #EthMainnet(
      ?[
        #Llama,
        // #Alchemy,
        // #Cloudflare
      ]
    );

    // Base Mainnet RPC providers
    // Get chain ID and RPC providers from https://chainlist.org/
    // let services : EvmRpc.RpcServices = #Custom {
    //   chainId = 8453;
    //   services = [
    //     {url = "https://base.llamarpc.com"; headers = null},
    //     {url = "https://base-rpc.publicnode.com"; headers = null}
    //   ];
    // };

    // Call `eth_getBlockByNumber` RPC method (unused cycles will be refunded)
    Cycles.add<system>(10_000_000_000);
    let result = await EvmRpc.eth_getBlockByNumber(services, null, #Number(height));

    switch result {
      // Consistent, successful results.
      case (#Consistent(#Ok block)) {
        block
      };
      // All RPC providers return the same error.
      case (#Consistent(#Err error)) {
        Debug.trap("Error: " # debug_show error)
      };
      // Inconsistent results between RPC providers. Should not happen if a single RPC provider is used.
      case (#Inconsistent(results)) {
        Debug.trap("Inconsistent results" # debug_show results)
      }
    }
  };

  public func get_ecdsa_public_key() : async Text {
    let {public_key} = await IC.ecdsa_public_key({
      canister_id = null;
      derivation_path = [];
      key_id = {curve = #secp256k1; name = key_name}
    });
    Base16.encode(public_key)
  };

  public func sign_message_with_ecdsa(message : Text) : async Text {
    let message_hash : Blob = Sha256.fromBlob(#sha256, Text.encodeUtf8(message));
    Cycles.add<system>(25_000_000_000);
    let {signature} = await IC.sign_with_ecdsa({
      message_hash;
      derivation_path = [];
      key_id = {curve = #secp256k1; name = key_name}
    });
    Base16.encode(signature)
  };

  public func get_schnorr_public_key() : async Text {
    let {public_key} = await IC.schnorr_public_key({
      canister_id = null;
      derivation_path = [];
      key_id = {algorithm = #ed25519; name = key_name}
    });
    Base16.encode(public_key)
  };

  public func sign_message_with_schnorr(message : Text) : async Text {
    Cycles.add<system>(25_000_000_000);
    let {signature} = await IC.sign_with_schnorr({
      message = Text.encodeUtf8(message);
      derivation_path = [];
      key_id = {algorithm = #ed25519; name = key_name};
      aux = null
    });
    Base16.encode(signature)
  }
};
ollama serve
# Expected to start listening on port 11434 import EvmRpc "canister:evm_rpc";
import IC "ic:aaaaa-aa";
import Sha256 "mo:sha2/Sha256";
import Base16 "mo:base16/Base16";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";

actor EvmBlockExplorer {
  let key_name = "test_key_1"; // Use "key_1" for production and "dfx_test_key" locally

  public func get_evm_block(height : Nat) : async EvmRpc.Block {
    let services : EvmRpc.RpcServices = #EthMainnet(
      ?[
        #Llama,
        // #Alchemy,
        // #Cloudflare
      ]
    );

    Cycles.add<system>(10_000_000_000);
    let result = await EvmRpc.eth_getBlockByNumber(services, null, #Number(height));

    switch result {
      case (#Consistent(#Ok block)) {
        block
      };
      case (#Consistent(#Err error)) {
        Debug.trap("Error: " # debug_show error)
      };
      case (#Inconsistent(results)) {
        Debug.trap("Inconsistent results" # debug_show results)
      }
    }
  };

  public func get_ecdsa_public_key() : async Text {
    let {public_key} = await IC.ecdsa_public_key({
      canister_id = null;
      derivation_path = [];
      key_id = {curve = #secp256k1; name = key_name}
    });
    Base16.encode(public_key)
  };

  public func sign_message_with_ecdsa(message : Text) : async Text {
    let message_hash : Blob = Sha256.fromBlob(#sha256, Text.encodeUtf8(message));
    Cycles.add<system>(25_000_000_000);
    let {signature} = await IC.sign_with_ecdsa({
      message_hash;
      derivation_path = [];
      key_id = {curve = #secp256k1; name = key_name}
    });
    Base16.encode(signature)
  };

  public func get_schnorr_public_key() : async Text {
    let {public_key} = await IC.schnorr_public_key({
      canister_id = null;
      derivation_path = [];
      key_id = {algorithm = #secp256k1; name = key_name}; // FIXED: use #secp256k1
    });
    Base16.encode(public_key)
  };

  public func sign_message_with_schnorr(message : Text) : async Text {
    Cycles.add<system>(25_000_000_000);
    let {signature} = await IC.sign_with_schnorr({
      message = Text.encodeUtf8(message);
      derivation_path = [];
      key_id = {algorithm = #secp256k1; name = key_name}; // FIXED: use #secp256k1
      aux = null
    });
    Base16.encode(signature)
  }
};
mode = variant {install} * ` wasm_memory_size ` : Represents the Wasm memory usage of the canister;
i.e.the heap memory used by the canister 's WebAssembly code.

* ` stable_memory_size ` : Represents the stable memory usage of the canister.

* ` global_memory_size ` : Represents the memory usage of the global variables that the canister is using.

* ` wasm_binary_size ` : Represents the memory occupied by the Wasm binary that is currently installed on the canister.This is the size of the binary uploaded via ` install_code ` or ` install_chunked_code `;
e.g.;
the compressed size if the uploaded binary is gzipped.

* ` custom_sections_size ` : Represents the memory used by custom sections defined by the canister;
which may include additional metadata or configuration data.

* ` canister_history_size ` : Represents the memory used for storing the canister 's history.

* ` wasm_chunk_store_size ` : Represents the memory used by the Wasm chunk store of the canister.

* ` snapshots_size ` : Represents the memory consumed by all snapshots that belong to this canister.
[workspace]
members = [
    "backend/rs/ic_vetkeys",
    "backend/rs/ic_vetkeys_test_utils",
    "backend/rs/canisters/ic_vetkeys_encrypted_maps_canister",
    "backend/rs/canisters/ic_vetkeys_manager_canister",
    "backend/rs/canisters/tests",
    "examples/basic_ibe/backend",
    "examples/basic_timelock_ibe/backend",
    "examples/password_manager_with_metadata/backend"
]
resolver = "2"

[workspace.package]
authors = ["DFINITY Stiftung"]
version = "0.1.0"
edition = "2021"
license = "Apache-2.0"
description = "Tools and examples for development with vetKeys on the Internet Computer"
repository = "https://github.com/dfinity/vetkeys"
rust-version = "1.75.0"
documentation = "https://docs.rs/ic-vetkeys"

[workspace.dependencies]
anyhow = "1.0.95"
candid = "0.10.2"
hex = "0.4.3"
ic-cdk = "0.18.3"
ic-cdk-macros = "0.18.3"
ic-stable-structures = "0.6.8"
lazy_static = "1.5.0"
pocket-ic = "9.0.0"
rand = "0.8.5"
rand_chacha = "0.3.1"
serde = "1.0.217"
serde_bytes = "0.11.15"
serde_cbor = "0.11.2"
serde_with = "3.11.0"
ic-dummy-getrandom-for-wasm = "0.1.0"

[profile.release]
lto = true
opt-level = 'z'
panic = 'abort'
7357l-qewss-qxuo3-ccvfm-6ofer-bameo-jmkvh-kzlxv-vs4w7-zauoh-jae

sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
