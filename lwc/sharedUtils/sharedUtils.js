import { LightningElement } from 'lwc';

const getQueryParameters = () => {
  let params = {};
  const search = window.location.search.substring(1);

  if (search) {
    params = JSON.parse(`{"${search.replace(/&/g, '","').replace(/=/g, '":"')}"}`, (key, value) => {
      if (key === '') {
        return value;
      }

      return decodeURIComponent(value);
    });
  }

  return params;
};


export {
  getQueryParameters,
}
