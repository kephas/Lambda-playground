(in-package :thierry-technologies.com/2011/07/lambda)

(defgeneric render (expression &key rightmost redex))

(defmethod render ((expression abstraction) &key (rightmost t) redex)
  (let ((rendering (format nil "λ~a.~a" (render (abs-var expression)) (render (abs-body expression) :redex redex))))
    (if rightmost rendering (format nil "(~a)" rendering))))

(defmethod render ((expression hidden-abstraction) &key rightmost redex)
  (hid-name expression))

(defmethod render ((expression variable) &key rightmost redex)
  (var-name expression))

(defmethod render ((expression application) &key (rightmost t) redex)
  (format nil (if (eq redex expression) "~a‸~a" "~a ~a")
	  (render (app-fun expression) :rightmost nil :redex redex)
	  (let* ((arg (app-arg expression))
		 (arg-rendering (render arg :rightmost rightmost :redex redex)))
	    (if (typep arg 'application)
		(format nil "(~a)" arg-rendering)
		arg-rendering))))

(defmethod print-object ((object expression) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (princ (render object) stream)))
