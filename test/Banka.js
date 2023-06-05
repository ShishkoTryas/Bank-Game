const { expect } = require("chai");
const { ethers, network} = require("hardhat");

let accounts;
let myBankaGameContract;


describe("Banka Game", function() {
    it("Contract should be successfully deployed, account 0 is owner", async function() {
        accounts = await ethers.getSigners();
        let BankaGameContract = await ethers.getContractFactory("Banka");
        myBankaGameContract = await BankaGameContract.deploy(10)
        await myBankaGameContract.deployed();
        expect(await myBankaGameContract.owner()).to.equal(accounts[0].address);
    });
    it("the commissions are set correctly", async function() {
        console.log(await myBankaGameContract.Comission());
        expect(await myBankaGameContract.Comission()).to.equal(10);
    });
    it("game started and counter increment", async function() {
        const sentETH = ethers.utils.parseEther("1.0")

        const transactionHash = await myBankaGameContract.startGame(1, {
            value: sentETH,
        });

        expect(await myBankaGameContract.counter()).to.equal(1);
    });
    it("game started true", async function() {
        expect((await myBankaGameContract.Games(1)).started).to.be.true;
    });

    it("game started max bet correct", async function() {
        const sentETH = ethers.utils.parseEther("1.0")
        expect((await myBankaGameContract.Games(1)).maxBet).to.be.equal(sentETH);
    });

    it("game started reverted", async function() {
        const sentETH = ethers.utils.parseEther("0.0");
        await expect(myBankaGameContract.startGame(2, { value: sentETH })).to.be.revertedWith("To start the game, the transaction must be greater than 0");
    });

    it("Game not started", async function() {
        await expect(myBankaGameContract.connect(accounts[1]).Bet(10)).to.be.revertedWith("Games not started yet");
    });

    it("The bet must be higher than the maximal last bet", async function() {
        await expect(myBankaGameContract.Bet(1, {value: ethers.utils.parseEther("0.5")})).to.be.revertedWith("The bet must be higher than the maximum");
    })

    it("The bet is right", async function() {
        const sentETH = ethers.utils.parseEther("2.0");
        await myBankaGameContract.connect(accounts[2]).Bet(1, {value: sentETH});
        expect((await myBankaGameContract.Games(1)).bank).to.be.equal(ethers.utils.parseEther("3.0"));

        expect((await myBankaGameContract.Games(1)).maxBet).to.be.equal(sentETH);

        expect((await myBankaGameContract.Games(1)).winner).to.be.equal(accounts[2].address);
    });

    it("Conclusion before the game is over", async function() {
        await expect(myBankaGameContract.winthrdraw(10)).to.be.revertedWith("Games not started yet");
    });

    it("The game is still going on", async function() {
        await expect(myBankaGameContract.winthrdraw(1)).to.be.revertedWith("Voting is not over yet!");
    });

    it("Voting is ended", async function() {
       await network.provider.send("evm_increaseTime",[500]);
       await expect(myBankaGameContract.Bet(1)).to.be.revertedWith("Voting is ended");
    });

    it("Not the winner wants to take the prize", async function() {
       await expect(myBankaGameContract.connect(accounts[5]).winthrdraw(1)).to.be.revertedWith("You are not a winner!");
    });

})