/**
 *Created by Mikael Lindahl on 2022-04-29
 */

import {createSlice, PayloadAction} from '@reduxjs/toolkit'

export type UserData ={
    url: string,
    name: string,
    created_at: string,
    updated_at: string,
    id: number
}

type TState = {
    value: UserData[]
}

// Define the initial state using that type
const initialState: TState = {value: []}


export const userDataSlice = createSlice({
    name: 'userData',
    initialState,
    reducers: {
        deleteUserData: (state, action:PayloadAction<number>) => {

            const values = state.value.filter(e => e.id != action.payload)

            state.value = values
        },
        setUserData: (state, action:PayloadAction<UserData[]>) => {

            state.value = action.payload
        },
        updateUserData: (state, action:PayloadAction<UserData>) => {

            const index = state.value.findIndex(e => e.id == action.payload.id)

            let value = [...state.value]
            if (index > -1) {
                value[index] = action.payload
            } else {
                value = [...value, action.payload]
            }
            state.value = value
        }
    },
})

// Action creators are generated for each case reducer function
export const {deleteUserData, setUserData, updateUserData} = userDataSlice.actions

export default userDataSlice.reducer