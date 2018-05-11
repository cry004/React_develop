const constants = {
  graph: {
    canvasW: 130,
    canvasH: 130,
    centerX: 65,
    centerY: 65,
    radius: 65,
    startRad: -90
  },
  subjectColor: {
    english: '#f23a1c',
    math: '#008eff',
    mathematics: '#008eff',
    science: '#00ae3a',
    society: '#00ae3a',
    social_studies: '#ffab1b',
    japanese: '#f34bc0'
  },
  subjects: [
    {
      id: 0,
      title: 'english',
      label: '英語'
    },
    {
      id: 1,
      title: 'mathematics',
      label: '数学'
    },
    {
      id: 2,
      title: 'science',
      label: '理科'
    },
    {
      id: 3,
      title: 'social_studies',
      label: '社会'
    },
    {
      id: 4,
      title: 'japanese',
      label: '国語'
    }
  ],
  nickNameLength: {
    min: 2,
    max: 16
  }
};

export default constants