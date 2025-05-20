const express = require("express");
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const StablePoolAbi = require("./abi/StablePool.json");
const GaugeAbi = require("./abi/Gauge.json");
const veCRVAbi = require("./abi/veCRV.json");
const GovernanceAbi = require("./abi/Governance.json");
const CurveFactoryAbi = require("./abi/CurveFactory.json");

dotenv.config();

const app = express();
app.use(express.json());

// Setup provider and signer
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Contract addresses (replace with real ones after deployment)
const addresses = {
  stablePool: "YourStablePoolAddress",
  gauge: "YourGaugeAddress",
  veCRV: "YourVeCRVAddress",
  governance: "YourGovernanceAddress",
  factory: "YourFactoryAddress",
};

const stablePool = new ethers.Contract(
  addresses.stablePool,
  StablePoolAbi,
  wallet
);
const gauge = new ethers.Contract(addresses.gauge, GaugeAbi, wallet);
const veCRV = new ethers.Contract(addresses.veCRV, veCRVAbi, wallet);
const governance = new ethers.Contract(
  addresses.governance,
  GovernanceAbi,
  wallet
);
const factory = new ethers.Contract(addresses.factory, CurveFactoryAbi, wallet);

// Routes
app.post("/add-liquidity", async (req, res) => {
  const { amount0, amount1 } = req.body;
  try {
    const tx = await stablePool.addLiquidity(amount0, amount1);
    await tx.wait();
    res.json({ status: "success", tx: tx.hash });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/stake", async (req, res) => {
  const { amount } = req.body;
  try {
    const tx = await gauge.deposit(amount);
    await tx.wait();
    res.json({ status: "staked", tx: tx.hash });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/lock-crv", async (req, res) => {
  const { amount, unlockTime } = req.body;
  try {
    const tx = await veCRV.lock(amount, unlockTime);
    await tx.wait();
    res.json({ status: "locked", tx: tx.hash });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/vote", async (req, res) => {
  const { proposalId, support } = req.body;
  try {
    const tx = await governance.vote(proposalId, support);
    await tx.wait();
    res.json({ status: "voted", tx: tx.hash });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/create-pool", async (req, res) => {
  const { token0, token1 } = req.body;
  try {
    const tx = await factory.deployPool(token0, token1);
    const receipt = await tx.wait();
    const event = receipt.logs.find(
      (l) => l.topics[0] === ethers.id("PoolCreated(address)")
    );
    const newPoolAddress = "0x" + event.topics[1].slice(26);
    res.json({ status: "created", pool: newPoolAddress });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Curve backend running on port ${PORT}`);
});
