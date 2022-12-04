const fs = require('fs')
const ethers = require('ethers')

const generateRandomNumber = (maxValue) => {
    return Math.floor(Math.random() * (maxValue + 1))
}

const attributeMaxValues = [60, 60, 10, 40, 10, 100, 50, 60, 100, 10, 25, 30]


const main = async () => {
    const bytecode = makeBytecode()

    writeFoundryReadableToDisk(bytecode)
    
    // await writeToChain(bytecode)
}

const readTokenAttributes = (tokenId) => {
    const allAttributes = JSON.parse(fs.readFileSync('random5000NFTsReadable.txt', 'utf8'))

    return allAttributes[tokenId - 1]
}

const generateMasks = () => {
    const masks = []
    const shifts = []
    const template = '000000000000000000000000000000000000000000000000000000000000000000'
    let templateIdx = 0;
    for (let i = 0; i < attributeMaxValues.length; i++) {
        const attributeMaxValue = attributeMaxValues[i]
        const bitLength = Math.ceil(Math.log2(attributeMaxValue))
        const maskBinary = template.substring(0, templateIdx) + '1'.repeat(bitLength) + template.substring(templateIdx + bitLength)
        const maskHex = parseInt(maskBinary, 2).toString(16)
        masks.push(maskHex)
        shifts.push(66 - templateIdx - bitLength)

        templateIdx += bitLength
    }

    console.log(masks.join('\n'))
    console.log(shifts.join(','))

    return masks;
}

const writeFoundryReadableToDisk = (bytecode) => {
    const artifact = {
        bytecode: {
            object: bytecode
        }
    }

    fs.writeFileSync('artifacts/random5000NFTs.json', JSON.stringify(artifact))
}

const makeBytecode = () => {
    let resultBinary = generateNftAttributesInBinary()

    return makeDeployableBytecode(resultBinary)
}

const makeDeployableBytecode = (resultBinary) => {
    let resultHex = ''
    for (let i = 0; i < 360000; i += 4) {
        resultHex = resultHex + parseInt(resultBinary.substring(i, i + 4), 2).toString(16).toUpperCase()
    }

    return '600B5981380380925939F300' + resultHex
}

const generateNftAttributesInBinary = () => {
    let resultBinary = ''
    let resultReadable = []
    let nftBinary = ''
    for (let i = 0; i < 5000; ++i) {
        resultReadable.push([])

        for (const attributeMaxValue of attributeMaxValues) {
            const randomValue = generateRandomNumber(attributeMaxValue)
            const bitLength = Math.ceil(Math.log2(attributeMaxValue))
            nftBinary = nftBinary + randomValue.toString(2).padStart(bitLength, '0')
            resultReadable[i].push(randomValue)
        }
        // add six zeroes to round to 72 bits = 9 bytes

        resultBinary = resultBinary + '000000' + nftBinary

        nftBinary = ''
    }
    
    fs.writeFileSync('random5000NFTsReadable.txt', JSON.stringify(resultReadable))

    return resultBinary
}

main()

async function writeToChain(bytecode) {
    const provider = new ethers.providers.JsonRpcBatchProvider(`https://goerli.infura.io/v3/INFURA API KEY HERE`)
    const wallet = new ethers.Wallet('PRIVATE KEY HERE', provider)

    const tx = await wallet.sendTransaction({ to: null, data: '0x' + bytecode })

    console.log('deploying', tx.hash)

    await tx.wait()

    console.log('deployed')
}
