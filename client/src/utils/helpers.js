export const getCardImage = (cardName) => {
    try {
      return require(`../assets/cards-front/${cardName}.png`).default;
    } catch (err) {
      console.error(`Image not found for card: ${cardName}`);
      return null;
    }
  };