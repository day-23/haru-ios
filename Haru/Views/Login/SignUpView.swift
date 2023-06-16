//
//  SignUpView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/25.
//

import Photos
import SwiftUI

struct SignUpView: View {
    private var profileService: ProfileService = .init()

    @State private var nickname: String = ""
    @State private var haruId: String = ""

    @State private var isValidId: Bool = false
    @State private var isValidNickname: Bool = false

    @State private var isDuplicated: Bool = false
    @State private var isLongNickname: Bool = false
    @State private var isBadNickname: Bool = false
    @State private var isInvalidId: Bool = false // 영어 소문자, 숫자로만 이루어졌는가?
    @State private var isInvalidNickname: Bool = false

    @FocusState private var isIdFieldFocused: Bool
    @FocusState private var isNicknameFieldFocused: Bool
    @State private var hasIdFieldFocusAtLeastOnce: Bool = false
    @State private var hasNicknameFieldFocusAtLeastOnce: Bool = false

    @State private var isChangedByLengthOver = false

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 168.33, height: 84.74)
            .mask(
                Image("logo")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 168.33, height: 84.74)
            )
            .padding(.top, 42)
            .padding(.bottom, 90)

            Group {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("하루 ID")
                            .font(.pretendard(size: 20, weight: .bold))
                            .foregroundColor(Color(0x191919))

                        HStack(spacing: 0) {
                            TextField("", text: $haruId)
                                .font(.pretendard(size: 24, weight: .regular))
                                .foregroundColor(Color(0x191919))
                                .focused($isIdFieldFocused)
                                .placeholder(when: haruId.isEmpty) {
                                    Text("ID를 입력해 주세요")
                                        .font(.pretendard(size: 24, weight: .regular))
                                        .foregroundColor(Color(0xACACAC))
                                }
                                .onChange(of: haruId) { _ in
                                    if isDuplicated {
                                        isDuplicated = false
                                    }

                                    isValidId = false
                                    let regex = /^[a-z0-9]*$/
                                    if haruId.wholeMatch(of: regex) != nil {
                                        isInvalidId = false
                                    } else {
                                        isInvalidId = true
                                    }
                                }
                                .onChange(of: isIdFieldFocused) { _ in
                                    if isIdFieldFocused && !hasIdFieldFocusAtLeastOnce {
                                        hasIdFieldFocusAtLeastOnce = true
                                    }

                                    if haruId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        isValidId = false
                                        return
                                    }

                                    if !isIdFieldFocused {
                                        profileService.validateHaruId(
                                            haruId: haruId
                                        ) { result in
                                            switch result {
                                            case .success:
                                                isValidId = true
                                            case .failure(let error):
                                                switch error {
                                                case ProfileService.ProfileError.duplicated:
                                                    isDuplicated = true
                                                default:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }

                            if (hasIdFieldFocusAtLeastOnce && haruId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || isDuplicated || isInvalidId {
                                Image("cancel")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0xF71E58))
                            } else if isValidId {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0x1DAFFF))
                            }
                        }
                    }

                    Divider()
                        .padding(.leading, -16)
                        .padding(.trailing, -13)

                    VStack(alignment: .leading, spacing: 0) {
                        if hasIdFieldFocusAtLeastOnce && haruId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("반드시 입력해야 합니다.")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xF71E58))
                        } else if isDuplicated {
                            Text("중복된 아이디입니다.")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xF71E58))
                        } else if isInvalidId {
                            Text("영어 소문자, 숫자로만 이루어져야 합니다.")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xF71E58))
                        } else if isValidId {
                            Text("사용 가능한 아이디입니다.")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0x1DAFFF))
                        } else {
                            Text("하루 ID는 타 사용자가 나의 계정을 검색할 때 외에 노출되지 않습니다.")
                                .lineLimit(1)
                            Text("ID는 초기 생성 이후 변경이 가능합니다.")
                        }
                    }
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(Color(0xACACAC))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 58)
                    .padding(.trailing, -12)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("닉네임")
                            .font(.pretendard(size: 20, weight: .bold))
                            .foregroundColor(Color(0x191919))

                        HStack(spacing: 0) {
                            TextField("", text: $nickname)
                                .font(.pretendard(size: 24, weight: .regular))
                                .foregroundColor(Color(0x191919))
                                .focused($isNicknameFieldFocused)
                                .placeholder(when: nickname.isEmpty) {
                                    Text("최대 8글자를 입력해 주세요")
                                        .font(.pretendard(size: 24, weight: .regular))
                                        .foregroundColor(Color(0xACACAC))
                                }
                                .onChange(of: nickname) { newValue in
                                    if isBadNickname {
                                        isBadNickname = false
                                    }

                                    isValidNickname = false
                                    if newValue.count > 8 {
                                        isChangedByLengthOver = true
                                        isLongNickname = true
                                        nickname = String(newValue[newValue.startIndex ..< newValue.index(newValue.endIndex, offsetBy: -1)])
                                    } else {
                                        if isChangedByLengthOver {
                                            isChangedByLengthOver = false
                                        } else {
                                            isLongNickname = false
                                        }
                                    }
                                }
                                .onChange(of: isNicknameFieldFocused) { _ in
                                    if isNicknameFieldFocused && !hasNicknameFieldFocusAtLeastOnce {
                                        hasNicknameFieldFocusAtLeastOnce = true
                                    }

                                    if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        isValidNickname = false
                                    }

                                    if !isNicknameFieldFocused {
                                        profileService.validateNickname(nickname: nickname) { result in
                                            switch result {
                                            case .success:
                                                isValidNickname = true
                                            case .failure(let error):
                                                switch error {
                                                case ProfileService.ProfileError.badname:
                                                    isBadNickname = true
                                                default:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }

                            if (hasNicknameFieldFocusAtLeastOnce && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || isLongNickname || isBadNickname {
                                Image("cancel")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0xF71E58))
                            } else if isValidNickname {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0x1DAFFF))
                            }
                        }
                    }

                    Divider()
                        .padding(.leading, -16)
                        .padding(.trailing, -13)

                    VStack(alignment: .leading, spacing: 0) {
                        if hasNicknameFieldFocusAtLeastOnce && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("반드시 입력해야 합니다.")
                        } else if isBadNickname {
                            Text("사용이 불가능한 닉네임입니다.")
                        } else if isLongNickname {
                            Text("닉네임이 8글자를 초과했습니다.")
                        } else if isValidNickname {
                            Text("사용 가능한 닉네임입니다.")
                                .foregroundColor(Color(0x1DAFFF))
                        }
                    }
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(Color(0xF71E58))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.leading, 36)
            .padding(.trailing, 33)

            Spacer()

            Button {
                isIdFieldFocused = false
                isNicknameFieldFocused = false

                if haruId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                {
                    if haruId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        isInvalidId = true
                    }

                    if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        isInvalidNickname = true
                    }
                    return
                }

                if !isValidId || !isValidNickname {
                    return
                }

                if let user = Global.shared.user {
                    profileService.initUserProfileWithoutImage(
                        userId: user.id,
                        name: nickname,
                        haruId: haruId
                    ) { result in
                        switch result {
                        case .success(let response):
                            Global.shared.user = response
                        case .failure(let error):
                            switch error {
                            case ProfileService.ProfileError.badname:
                                isBadNickname = true
                            case ProfileService.ProfileError.duplicated:
                                isDuplicated = true
                            default:
                                break
                            }
                        }
                    }
                }
            } label: {
                Text("프로필 생성 완료")
                    .font(.pretendard(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 104)
                    .background(
                        LinearGradient(
                            colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .padding(.bottom, 75)
            .ignoresSafeArea(.keyboard)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isIdFieldFocused = false
            isNicknameFieldFocused = false
        }
    }
}
