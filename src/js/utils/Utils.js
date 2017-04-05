'use strict';

/* Toggles an elements class on and off
 * @param el HTML Element, clsOne String the active class string
 * @returns null
 */
export const toggleClass = (el, cls) => {
  const element = el;
  if (element.classList) {
    element.classList.toggle(cls);
  } else {
    const classes = element.className.split(' ');
    const existingIndex = classes.indexOf(cls);
    if (existingIndex >= 0) {
      classes.splice(existingIndex, 1);
    } else {
      classes.push(cls);
    }
    element.className = classes.join(' ');
  }
};

/* Toggles an elements class between two different classes
 * @param el HTML Element, clsOne String the first class string,
          clsTwo String the second class string
 * @returns null
 */
export const toggleBetweenClass = (el, clsOne, clsTwo) => {
  if (el.classList && el.classList.contains(clsOne)) {
    el.classList.remove(clsOne);
    el.classList.add(clsTwo);
  } else {
    el.classList.remove(clsTwo);
    el.classList.add(clsOne);
  }
};

/* Checks if element has class
 * @param el HTML Element, cls String the class string
 * @returns Bool
 */
export const hasClass = (el, cls) => el.className && new RegExp(`(\\s|^)${cls}(\\s|$)`).test(el.className);

/* Gets closest element with a specific class
 * @param el HTML Element, cls String the class string
 * @returns el HTML Element the HTML Element
 */
export const closest = (el, cls) => {
  let element = el;
  while (element.className !== cls) {
    element = element.parentNode;
    if (!element) {
      return null;
    }
  }
  return element;
};

/* Converts a JSON string to a JavaScript object
 * @param str String the JSON string
 * @returns obj Object the JavaScript object
 */
export const toJSONObject = (str) => {
  const obj = JSON.parse(str);
  return obj;
};

/* Converts a JavaScript object to a JSON string
 * @param obj Object the JavaScript object
 * @returns str String the JSON string
 */
export const toJSONString = (obj) => {
  const str = JSON.stringify(obj);
  return str;
};

/* Checks if value exists in associative array
 * @param arr array to search
 * @param key key to use in search
 * @param str string to check for
 * @returns index if found | -1 if not found
 */
export const inObject = (arr, key, str) => {
  let i = 0;
  while (i < arr.length) {
    if (arr[i][key] === str) {
      return i;
    }
    i += 1;
  }
  return -1;
};
