import 'emoji-picker-element';

const ReactionPicker = {
  mounted() {
    // const button = this.el.querySelector('.reaction-button');
    const picker = this.el.querySelector('emoji-picker');
    const objectId = this.el.dataset.objectId;

    picker.addEventListener('emoji-click', event => {
      console.log(event.detail)
      const emoji = event.detail.unicode;
      // Send the reaction to the server
      this.pushEvent("Bonfire.Social.Likes:add_reaction", {
        emoji: emoji,
        id: objectId
      }); 

    });
  }
};

export default ReactionPicker;