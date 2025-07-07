package models

// ErrorResponse representa uma resposta de erro da API
type ErrorResponse struct {
	Error string `json:"error" example:"Mensagem de erro"`
}

// MessageResponse representa uma resposta com mensagem de sucesso
type MessageResponse struct {
	Message string `json:"message" example:"Operação realizada com sucesso"`
}

// UserResponse representa a resposta ao registrar um usuário
type UserResponse struct {
	Message string `json:"message" example:"Usuário registrado com sucesso"`
	User    User   `json:"user"`
}

// LoginResponse representa a resposta do login
type LoginResponse struct {
	Message string `json:"message" example:"Login realizado com sucesso"`
	Token   string `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

// TodoListResponse representa a resposta da listagem de todos
type TodoListResponse struct {
	Data    []Todo      `json:"data"`
	Total   int64       `json:"total"`
	Page    int         `json:"page"`
	Limit   int         `json:"limit"`
	Filters interface{} `json:"filters"`
}

// DeleteTodoResponse representa a resposta ao deletar um todo
type DeleteTodoResponse struct {
	Message string `json:"message" example:"Tarefa deletada com sucesso"`
	ID      uint   `json:"id" example:"1"`
}

// MeResponse representa a resposta da rota /me
type MeResponse struct {
	Message string `json:"message" example:"Área protegida"`
	UserID  uint   `json:"user_id" example:"1"`
}
