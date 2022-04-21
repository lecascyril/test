const {Moralis} = useMoralis();
const {abi} = Voting.json // juste l'abi dans un fichier
const options= {abi, contractAddress: anAddress}
const runFunc= async (params) => {
	let x = await Moralis.executeFunction({functionName: "aFunction", params: {params}, msgValue: xx})
}
