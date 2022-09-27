# ERC721_with_p2p_market

Inside this contract, the mechanics of the p2p NFT market are implemented

If you want to list your nft, then you need to call "list" function and enter the ID of the NFT you want to sell and the price in native network tokens for which you would like to sell this nft

To buy nft you need to call "buy" function and enter the ID of the NFT you want to buy there, as well as transfer the necessary amount of the network's native token for the purchase

If you want to delist of your NFT, then you need to call the function "stopListing"

All transactions carried out on this p2p market are subject to a commission. The amount of all commissions from all transactions is evenly distributed among all holders of the NFT collection. To distribute them you need to call "withdrawAllComissions"
