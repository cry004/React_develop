import request from 'superagent'

let instance = null
const body = document.getElementById("body")
const apiDomain = body.getAttribute('data-student-api')

class ApiClient {


  // ==========================
  // # login
  // ==========================
  postLoginApi(login) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/login`)
        .send({
          studentId: login.id,
          password: login.password
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  // ==========================
  // # logout
  // ==========================
  logoutApi(args) {
    return new Promise((resolve, reject) => {
      request
        .delete(`${apiDomain}/api/v5/logout`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(res)
            }
          }
        )
    })
  }


  // ==========================
  // # search
  // ==========================
  fetchSearchWordsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/searched_words`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  postSearchedWordApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/searched_words`)
        .set('X-Authorization', args.accessToken)
        .send({
          searched_word: args.searchedWord,
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchSearchVideosApi(args) {
    let param = {
      keyword: args.keyword,
      page: args.page,
      per_page: args.perPage
    }
    if (args.grade !== "") {
      param["grade"] = args.grade
    }
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/videos/search`)
        .set('X-Authorization', args.accessToken)
        .query(param)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchSearchUnitsApi(args) {
    const params = {
      title: args.title,
      title_description: args.titleDescription,
      schoolbook_id: args.schoolbookId
    }
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/units/videos`)
        .set('X-Authorization', args.accessToken)
        .query(params)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  // ==========================
  // # videoTags
  // ==========================
  fetchVideoTagsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/video_tags`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # students
  // ==========================
  postUserApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/students/me`)
        .type('form')
        .send({
          nick_name: args.nickName,
          avatar: args.avatar
        })
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchUserApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/students/me`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  requestSchoolbooksApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/students/me/schoolbooks`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updateSchoolbooksApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/students/me/schoolbooks`)
        .set('X-Authorization', args.accessToken)
        .type('form')
        .send({
          schoolbooks: args.book
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  putSchoolbookDialogsApi(args) {
      return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/students/me/schoolbook_dialogs`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchPrivacySettingsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/students/me/privacy_settings`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updatePrivateFlagApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/students/me/privacy_settings`)
        .set('X-Authorization', args.accessToken)
        .send({
          private_flag: args.privateFlag,
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # questions
  // ==========================
  fetchQuestionApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/questions/${args.id}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchQuestionsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/questions?page=${args.page}&par_page=${args.perPage}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  deleteQuestionsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .del(`${apiDomain}/api/v5/questions/${args.deleteId}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(res.status)
            }
          }
        )
    })
  }
  createQuestionApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/questions`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  createQuestionByVideoApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/questions`)
        .set('X-Authorization', args.accessToken)
        .send({
          video_id: args.videoId,
          position: args.position
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updateQuestionApi(args) {
    return new Promise((resolve, reject) => {
      if (args.withoutVideo.course_name) {
        request
          .put(`${apiDomain}/api/v5/questions/${args.questionId}`)
          .set('X-Authorization', args.accessToken)
          .field('create_flag', args.createFlag)
          .field('without_video[body]', args.withoutVideo.body)
          .field('without_video[course_name]', args.withoutVideo.course_name || null)
          .attach('without_video[upload_file]', args.withoutVideo.upload_file || null)
          .end(
            (err, res) => {
              if (err) {
                reject(JSON.parse(err.response.text))
              } else {
                resolve(JSON.parse(res.text))
              }
            }
          ) 
      } else {
        request
          .put(`${apiDomain}/api/v5/questions/${args.questionId}`)
          .set('X-Authorization', args.accessToken)
          .field('create_flag', args.createFlag)
          .field('without_video[body]', args.withoutVideo.body)
          .attach('without_video[upload_file]', args.withoutVideo.upload_file || null)
          .end(
            (err, res) => {
              if (err) {
                reject(JSON.parse(err.response.text))
              } else {
                resolve(JSON.parse(res.text))
              }
            }
          )
      }
    })
  }
  updateQuestionByVideoApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/questions/${args.questionId}`)
        .set('X-Authorization', args.accessToken)
        .send({
          create_flag: args.createFlag,
          with_video: args.withVideo
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchQuestionDraftApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/questions/${args.id}/drafts`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updateQuestionReadApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/questions/${args.id}/reads`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  resolveQuestionApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/questions/${args.id}/resolves`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  unresolveQuestionApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/questions/${args.id}/unresolves`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchVacationApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/questions/createability`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # workbooks
  // ==========================
  fetchWorkbooksApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/workbooks`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  // ==========================
  // # teacher_recommendations
  // ==========================
  fetchTeacherRecommendsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/teacher_recommendations?page=${args.page}&per_page=${args.perPage}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchTeacherDetailApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/teacher_recommendations/${args.id}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updateReadTeacherDetailApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/teacher_recommendations/${args.id}/reads`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # videos
  // ==========================
  fetchHistoriesApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/videos/histories?page=${args.page}&par_page=${args.perPage}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchVideoApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/videos/${args.id}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchVideosApi(args) {
    return new Promise((resolve, reject) => {
      request  
        .get(`${apiDomain}/api/v5/videos/${args.year}/${args.subject}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  postVideoWatchedApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/videos/${args.id}/watches`)
        .set('X-Authorization', args.accessToken)
        .send({
          id: args.id,
          viewed_time: args.playTime
        })
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchVideoDetailApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/videos/${args.id}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  postBookmarkApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/videos/${args.videoId}/bookmarks`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  deleteBookmarkApi(args) {
    return new Promise((resolve, reject) => {
      request
        .del(`${apiDomain}/api/v5/videos/${args.videoId}/bookmarks`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(res)
            }
          }
        )
    })
  }
  fetchBookmarksApi(args) {
    let params = {
      par_page: args.perPage
    }
    if (args.maxId !== null) {
      params["max_id"] = args.maxId
    }
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/videos/bookmarks`)
        .set('X-Authorization', args.accessToken)
        .query(params)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  postPlayAndPositionBarClickApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/videos/${args.videoId}/plays?position=${args.position}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  // ==========================
  // # news
  // ==========================
  fetchNewsApi(args) {
    let params = {
      par_page: args.perPage
    }
    if (args.maxId !== null) {
      params["max_id"] = args.maxId
    }
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/news`)
        .set('X-Authorization', args.accessToken)
        .query(params)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchNewsDetailApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/news/${args.id}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  updateReadNewsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .put(`${apiDomain}/api/v5/news/${args.id}/reads`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # notifications
  // ==========================
  fetchNotificationsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/notifications`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # rankings
  // ==========================
  fetchRankingsPersonalApi(args) {
    const region = args.region === 'schoolhouse' ? 'classroom' : args.region
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/rankings/personal?ranking_type=${region}&period_type=${args.term}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchRankingsPersonalsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/rankings/personals?period_type=${args.term}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchRankingsClassroomApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/rankings/classroom?ranking_type=${args.region}&period_type=${args.term}&classroom_type=${args.classroomType}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchRankingsClassroomsApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/rankings/classrooms?period_type=${args.term}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # point_requests
  // ==========================
  sendPointRequestApi(args) {
    return new Promise((resolve, reject) => {
      request
        .post(`${apiDomain}/api/v5/point_requests`)
        .type('form')
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # learning_progresses
  // ==========================
  fetchLearningProgressesApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/learning_progresses`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }


  // ==========================
  // # courses
  // ==========================
  fetchCoursesApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/courses?course_name=${args.cource}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }

  // ==========================
  // # juku_learnings
  // ==========================
  fetchJukuLearningsCurrentApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/juku_learnings/currents`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
  fetchJukuLearningsArchivesApi(args) {
    return new Promise((resolve, reject) => {
      request
        .get(`${apiDomain}/api/v5/juku_learnings/archives?page=${args.page}&par_page=${args.perPage}`)
        .set('X-Authorization', args.accessToken)
        .end(
          (err, res) => {
            if (err) {
              reject(JSON.parse(err.response.text))
            } else {
              resolve(JSON.parse(res.text))
            }
          }
        )
    })
  }
}

module.exports = (function () {
  if (instance != null) {
    return instance;
  }
  instance = new ApiClient();
  return instance;
})();