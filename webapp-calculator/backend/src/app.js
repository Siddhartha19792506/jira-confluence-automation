import express from "express";

const app = express();

app.use(express.json());

app.get("/api/health", (_req, res) => {
	res.status(200).json({ status: "ok" });
});

app.get("/api/readiness", (_req, res) => {
	res.status(200).json({ status: "ready" });
});

export default app;
