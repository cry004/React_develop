export const SHOW_EXPERIENCE = 'SHOW_EXPERIENCE'
export const HIDE_EXPERIENCE = 'HIDE_EXPERIENCE'

export function showExperience(experience = 0) {
  return {
    type: SHOW_EXPERIENCE,
    experience: experience,
    experienceIsShow: true
  }
}

export function hideExperience() {
  return {
    type: HIDE_EXPERIENCE,
    experienceIsShow: false
  }
}