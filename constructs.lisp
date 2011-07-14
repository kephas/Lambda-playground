(in-package :thierry-technologies.com/2011/07/lambda)


#| Basic constructs of lambda calculus |#

(defclass expression () ())

(defclass variable (expression)
  ((name :accessor var-name :initarg :name)))

(defclass abstraction (expression)
  ((variable :accessor abs-var :initarg :var)
   (body :accessor abs-body :initarg :body)))

(defclass application (expression)
  ((function :accessor app-fun :initarg :fun)
   (argument :accessor app-arg :initarg :arg)))


#| A hidden abstraction is rendered by its name
instead of its content |#

(defclass hidden-abstraction (abstraction)
  ((content :reader hid-abs :initarg :abs)
   (name :reader hid-name :initarg :name)))

(defmethod abs-var ((object hidden-abstraction))
  (abs-var (hid-abs object)))

(defmethod abs-body ((object hidden-abstraction))
  (abs-body (hid-abs object)))



#| Building of lambda expressions for symbolic expressions |#

(defgeneric make-expression (sexpr &optional environment))

(defmethod make-expression ((sexpr expression) &optional environment)
  sexpr)

(defmethod make-expression ((sexpr string)  &optional environment)
  (let ((hidden (find sexpr environment :key #'hid-name :test #'equal)))
    (if hidden
	hidden
	(make-instance 'variable :name sexpr))))

(defmethod make-expression ((sexpr symbol)  &optional environment)
  (make-expression (string-downcase (symbol-name sexpr))))

(defmethod make-expression ((sexpr cons)  &optional environment)
  (case (first sexpr)
    ((lambda) (make-instance 'abstraction :var (make-expression (second sexpr)) :body (make-expression (third sexpr) environment)))
    (t (make-applications-chain
	(make-instance 'application :fun (make-expression (first sexpr) environment) :arg (make-expression (second sexpr) environment))
	(cddr sexpr)
	environment))))

(defun make-applications-chain (fun sexpr &optional environment)
  (if (null sexpr)
      fun
      (make-applications-chain (make-instance 'application
					      :fun fun
					      :arg (make-expression (first sexpr) environment))
			       (rest sexpr)
			       environment)))
