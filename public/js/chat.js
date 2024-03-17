function formatTimeAgo(date) {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const yesterday = new Date(today);
  yesterday.setDate(today.getDate() - 1);
  const diffTime = now - date;
  const diffMinutes = Math.floor(diffTime / (1000 * 60));
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

  if (date.toDateString() === yesterday.toDateString()) {
    return "yesterday";
  } else if (date.toDateString() === today.toDateString()) {
    if (diffMinutes < 60) {
      return `${diffMinutes} minutes ago`;
    } else {
      return `${diffHours} hours ago`;
    }
  } else {
    return `${diffDays} days ago`;
  }
}
