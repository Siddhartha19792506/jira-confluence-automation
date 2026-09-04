import React from "react";
import { NavLink, Route, Routes } from "react-router-dom";

function Page({ title, children }) {
	return (
		<section className="card">
			<h2>{title}</h2>
			<p>{children}</p>
		</section>
	);
}

export default function App() {
	return (
		<div className="app-shell">
			<header className="hero">
				<h1>Jira/Confluence Automation</h1>
				<p>MVP shell with dashboard, run workflow, and history routes.</p>
			</header>

			<nav className="nav">
				<NavLink to="/" end>
					Dashboard
				</NavLink>
				<NavLink to="/run">Run Workflow</NavLink>
				<NavLink to="/history">History</NavLink>
			</nav>

			<main>
				<Routes>
					<Route
						path="/"
						element={<Page title="Dashboard">System overview and quick actions.</Page>}
					/>
					<Route
						path="/run"
						element={<Page title="Run Workflow">Trigger Jira fetch and Confluence update.</Page>}
					/>
					<Route
						path="/history"
						element={<Page title="Run History">Recent workflow runs and statuses.</Page>}
					/>
				</Routes>
			</main>
		</div>
	);
}
