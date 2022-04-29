/**
 *Created by Mikael Lindahl on 2022-04-29
 */

import { createSlice } from '@reduxjs/toolkit'

export const userDataSlice = createSlice({
    name: 'userData',
    initialState: {
        value: [],
    },
    reducers: {
        setUserData: (state, action) => {

            state.value = action.payload
        },
        updateUserData: (state, action) => {

            const index = state.value.findIndex(e=>e.id==action.payload.id)

            let value = [...state.value]
            if(index>-1){
                value[index]=action.payload
            }else{
                value=[...value, action.payload]
            }
            state.value = value
        }
    },
})

// Action creators are generated for each case reducer function
export const { setUserData, updateUserData } = userDataSlice.actions

export default userDataSlice.reducer