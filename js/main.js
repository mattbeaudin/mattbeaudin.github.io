// Keep "years of experience" current: data-since holds the start year
document.querySelectorAll('[data-since]').forEach(el => {
	el.textContent = new Date().getFullYear() - el.dataset.since;
});
