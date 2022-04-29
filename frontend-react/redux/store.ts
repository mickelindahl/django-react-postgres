/**
 *Created by Mikael Lindahl on 2022-04-29
 */

import { configureStore } from '@reduxjs/toolkit'
import userDataReducer from "./slices/userDataSlice";
const store = configureStore({
    reducer: {
        userData:userDataReducer
    },
})

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>
// Inferred type: {posts: PostsState, comments: CommentsState, users: UsersState}
export type AppDispatch = typeof store.dispatch

export default store