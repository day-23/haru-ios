# haru
2023.10.15.(월) 토큰 테스트

## Commit Convention

1. `feature`: **새로운 기능 추가**
2. `fix`: **버그 수정**
3. `docs`: **문서 수정**
4. `style`: **코드 포맷팅 → Code Convention**
5. `refactor`: **코드 리팩토링**
6. `test`: **테스트 코드**
7. `chore`: **빌드 업무 수정, 패키지 매니저 수정**
8. `comment`: **주석 추가 및 수정**

커밋할 때 헤더에 위 내용을 작성하고 전반적인 내용을 간단하게 작성합니다.

### 예시

> `git commit -m "feature: 하루"`

커밋할 때 상세 내용을 작성해야 한다면 아래와 같이 진행합니다.

### 예시

> `git commit`  
> 어떠한 에디터로 진입하게 된 후 아래와 같이 작성합니다.  
> `[header]: 전반적인 내용`  
> . **(한 줄 비워야 함)**  
> `상세 내용`

## Branch Naming Convention

브랜치를 새롭게 만들 때, 브랜치 이름은 항상 위 `Commit Convention`의 Header와 함께 작성되어야 합니다.

### 예시

> `feature/haru`  
> `refactor/haru`

## Project Directory Structure

- Haru
  - Global  
    앱 전체와 관련된 파일들을 모아 놓은 폴더입니다.
  - Models  
    데이터 타입들을 모아놓은 파일은 모아 놓은 폴더입니다.  
    모델에게 필요한 헬퍼 함수도 같은 파일에 있습니다.
  - Services  
    API 호출이나 서버와의 통신과 같은 요청들을 모아 놓은 폴더입니다.
  - Views  
    사용자에게 보이는 View를 모아 놓은 폴더입니다.
  - ViewModels  
    View에 필요한 데이터를 전달하고 데이터 변경 로직이 있는 폴더입니다.
  - Extensions  
    Swift, module의 확장 코드를 모아 놓은 폴더입니다.
  - Enumerations  
    프로젝트에서 필요한 Enum 타입을 모아 놓은 폴더입니다.
  - Utilities  
    헬퍼 함수들이나 추가 프로토콜을 모아 놓은 폴더입니다.
