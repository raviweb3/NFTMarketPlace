import Navbar from "./Navbar";
import NFTTile from "./NFTTile";
import MarketplaceJSON from "../NFTMarketplace.json";
import axios from "axios";
import { useState } from "react";

export default function Marketplace() {
const sampleData = [
    {
        "name": "NFT#1",
        "description": "First NFT",
        "website":"http://google.com",
        "image":"https://ipfs.filebase.io/ipfs/QmRQeUWsLUNGws5bKgbmX9P8jhbsL9pxQpfQE84v5KV3SD/QmU4n2GGgySmbvuzfUdgGXdHP5mw6quMUzJAd99uFYHfo2",
        "price":"0.00ETH",
        "currentlySelling":"True",
        "address":"0x0000000000000000000000000000000000000000",
    },
    {
        "name": "NFT#2",
        "description": "Second NFT",
        "website":"http://google.com",
        "image":"https://ipfs.filebase.io/ipfs/QmRQeUWsLUNGws5bKgbmX9P8jhbsL9pxQpfQE84v5KV3SD/QmVhVEPv6jEBFseqgxznb8WE8YcgcPbgZ7mQWU2XyeaEFy",
        "price":"0.00ETH",
        "currentlySelling":"True",
        "address":"0x0000000000000000000000000000000000000000",
    },
    {
        "name": "NFT#3",
        "description": "Third NFT",
        "website":"http://google.com",
        "image":"https://ipfs.filebase.io/ipfs/QmRQeUWsLUNGws5bKgbmX9P8jhbsL9pxQpfQE84v5KV3SD/QmX8Nw741u18P1WSigaBu4aTvVFrGujUfF8w58ezMzNU8v",
        "price":"0.00ETH",
        "currentlySelling":"True",
        "address":"0x0000000000000000000000000000000000000000",
    },
];
const [data, updateData] = useState(sampleData);
const [dataFetched, updateFetched] = useState(false);

async function getAllNFTs() {
    const ethers = require("ethers");
    //After adding your Hardhat network to your metamask, this code will get providers and signers
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    //Pull the deployed contract instance
    let contract = new ethers.Contract(MarketplaceJSON.address, MarketplaceJSON.abi, signer)
    //create an NFT Token
    let transaction = await contract.getAllNFTs()

    //Fetch all the details of every NFT from the contract and display
    const items = await Promise.all(transaction.map(async i => {
        const tokenURI = await contract.tokenURI(i.tokenId);
        let meta = await axios.get(tokenURI);
        meta = meta.data;

        let price = ethers.utils.formatUnits(i.price.toString(), 'ether');
        let item = {
            price,
            tokenId: i.tokenId.toNumber(),
            seller: i.seller,
            owner: i.owner,
            image: meta.image,
            name: meta.name,
            description: meta.description,
        }
        return item;
    }))

    updateFetched(true);
    updateData(items);
}

if(!dataFetched)
    getAllNFTs();

return (
    <div>
        <Navbar></Navbar>
        <div className="flex flex-col place-items-center mt-20">
            <div className="md:text-xl font-bold text-white">
                Top NFTs
            </div>
            <div className="flex mt-5 justify-between flex-wrap max-w-screen-xl text-center">
                {data.map((value, index) => {
                    return <NFTTile data={value} key={index}></NFTTile>;
                })}
            </div>
        </div>            
    </div>
);

}