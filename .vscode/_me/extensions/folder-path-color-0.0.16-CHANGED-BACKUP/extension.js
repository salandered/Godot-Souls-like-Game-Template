(() => {
	"use strict";
	var t = {
		496: t => {
			t.exports = require("vscode")
		},
		17: t => {
			t.exports = require("path")
		},
		638: (t, e) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.range = e.balanced = void 0, e.balanced = (t, i, r) => {
				const n = t instanceof RegExp ? s(t, r) : t,
					o = i instanceof RegExp ? s(i, r) : i,
					a = null !== n && null != o && (0, e.range)(n, o, r);
				return a && {
					start: a[0],
					end: a[1],
					pre: r.slice(0, a[0]),
					body: r.slice(a[0] + n.length, a[1]),
					post: r.slice(a[1] + o.length)
				}
			};
			const s = (t, e) => {
				const s = e.match(t);
				return s ? s[0] : null
			};
			e.range = (t, e, s) => {
				let i, r, n, o, a, h = s.indexOf(t),
					l = s.indexOf(e, h + 1),
					p = h;
				if (h >= 0 && l > 0) {
					if (t === e) return [h, l];
					for (i = [], n = s.length; p >= 0 && !a;) {
						if (p === h) i.push(p), h = s.indexOf(t, p + 1);
						else if (1 === i.length) {
							const t = i.pop();
							void 0 !== t && (a = [t, l])
						} else r = i.pop(), void 0 !== r && r < n && (n = r, o = l), l = s.indexOf(e, p + 1);
						p = h < l && h >= 0 ? h : l
					}
					i.length && void 0 !== o && (a = [n, o])
				}
				return a
			}
		},
		910: (t, e, s) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.expand = function (t) {
				return t ? ("{}" === t.slice(0, 2) && (t = "\\{\\}" + t.slice(2)), E(function (t) {
					return t.replace(g, r).replace(d, n).replace(m, o).replace(b, a).replace(w, h)
				}(t), !0).map(S)) : []
			};
			const i = s(638),
				r = "\0SLASH" + Math.random() + "\0",
				n = "\0OPEN" + Math.random() + "\0",
				o = "\0CLOSE" + Math.random() + "\0",
				a = "\0COMMA" + Math.random() + "\0",
				h = "\0PERIOD" + Math.random() + "\0",
				l = new RegExp(r, "g"),
				p = new RegExp(n, "g"),
				c = new RegExp(o, "g"),
				u = new RegExp(a, "g"),
				f = new RegExp(h, "g"),
				g = /\\\\/g,
				d = /\\{/g,
				m = /\\}/g,
				b = /\\,/g,
				w = /\\./g;

			function y(t) {
				return isNaN(t) ? t.charCodeAt(0) : parseInt(t, 10)
			}

			function S(t) {
				return t.replace(l, "\\").replace(p, "{").replace(c, "}").replace(u, ",").replace(f, ".")
			}

			function v(t) {
				if (!t) return [""];
				const e = [],
					s = (0, i.balanced)("{", "}", t);
				if (!s) return t.split(",");
				const {
					pre: r,
					body: n,
					post: o
				} = s, a = r.split(",");
				a[a.length - 1] += "{" + n + "}";
				const h = v(o);
				return o.length && (a[a.length - 1] += h.shift(), a.push.apply(a, h)), e.push.apply(e, a), e
			}

			function x(t) {
				return "{" + t + "}"
			}

			function O(t) {
				return /^-?0\d/.test(t)
			}

			function M(t, e) {
				return t <= e
			}

			function A(t, e) {
				return t >= e
			}

			function E(t, e) {
				const s = [],
					r = (0, i.balanced)("{", "}", t);
				if (!r) return [t];
				const n = r.pre,
					a = r.post.length ? E(r.post, !1) : [""];
				if (/\$$/.test(r.pre))
					for (let t = 0; t < a.length; t++) {
						const e = n + "{" + r.body + "}" + a[t];
						s.push(e)
					} else {
					const i = /^-?\d+\.\.-?\d+(?:\.\.-?\d+)?$/.test(r.body),
						h = /^[a-zA-Z]\.\.[a-zA-Z](?:\.\.-?\d+)?$/.test(r.body),
						l = i || h,
						p = r.body.indexOf(",") >= 0;
					if (!l && !p) return r.post.match(/,(?!,).*\}/) ? E(t = r.pre + "{" + r.body + o + r.post) : [t];
					let c, u;
					if (l) c = r.body.split(/\.\./);
					else if (c = v(r.body), 1 === c.length && void 0 !== c[0] && (c = E(c[0], !1).map(x), 1 === c.length)) return a.map((t => r.pre + c[0] + t));
					if (l && void 0 !== c[0] && void 0 !== c[1]) {
						const t = y(c[0]),
							e = y(c[1]),
							s = Math.max(c[0].length, c[1].length);
						let i = 3 === c.length && void 0 !== c[2] ? Math.abs(y(c[2])) : 1,
							r = M;
						e < t && (i *= -1, r = A);
						const n = c.some(O);
						u = [];
						for (let o = t; r(o, e); o += i) {
							let t;
							if (h) t = String.fromCharCode(o), "\\" === t && (t = "");
							else if (t = String(o), n) {
								const e = s - t.length;
								if (e > 0) {
									const s = new Array(e + 1).join("0");
									t = o < 0 ? "-" + s + t.slice(1) : s + t
								}
							}
							u.push(t)
						}
					} else {
						u = [];
						for (let t = 0; t < c.length; t++) u.push.apply(u, E(c[t], !1))
					}
					for (let t = 0; t < u.length; t++)
						for (let i = 0; i < a.length; i++) {
							const r = n + u[t] + a[i];
							(!e || l || r) && s.push(r)
						}
				}
				return s
			}
		},
		402: (t, e) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.assertValidPattern = void 0, e.assertValidPattern = t => {
				if ("string" != typeof t) throw new TypeError("invalid pattern");
				if (t.length > 65536) throw new TypeError("pattern is too long")
			}
		},
		698: (t, e, s) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.AST = void 0;
			const i = s(802),
				r = s(157),
				n = new Set(["!", "?", "+", "*", "@"]),
				o = t => n.has(t),
				a = "(?!\\.)",
				h = new Set(["[", "."]),
				l = new Set(["..", "."]),
				p = new Set("().*{}+?[]^$\\!"),
				c = "[^/]",
				u = c + "*?",
				f = c + "+?";
			class g {
				type;
				#t;
				#e;
				#s = !1;
				#i = [];
				#r;
				#n;
				#o;
				#a = !1;
				#h;
				#l;
				#p = !1;
				constructor(t, e, s = {}) {
					this.type = t, t && (this.#e = !0), this.#r = e, this.#t = this.#r ? this.#r.#t : this, this.#h = this.#t === this ? s : this.#t.#h, this.#o = this.#t === this ? [] : this.#t.#o, "!" !== t || this.#t.#a || this.#o.push(this), this.#n = this.#r ? this.#r.#i.length : 0
				}
				get hasMagic() {
					if (void 0 !== this.#e) return this.#e;
					for (const t of this.#i)
						if ("string" != typeof t && (t.type || t.hasMagic)) return this.#e = !0;
					return this.#e
				}
				toString() {
					return void 0 !== this.#l ? this.#l : this.type ? this.#l = this.type + "(" + this.#i.map((t => String(t))).join("|") + ")" : this.#l = this.#i.map((t => String(t))).join("")
				}
				#c() {
					if (this !== this.#t) throw new Error("should only call on root");
					if (this.#a) return this;
					let t;
					for (this.toString(), this.#a = !0; t = this.#o.pop();) {
						if ("!" !== t.type) continue;
						let e = t,
							s = e.#r;
						for (; s;) {
							for (let i = e.#n + 1; !s.type && i < s.#i.length; i++)
								for (const e of t.#i) {
									if ("string" == typeof e) throw new Error("string part in extglob AST??");
									e.copyIn(s.#i[i])
								}
							e = s, s = e.#r
						}
					}
					return this
				}
				push(...t) {
					for (const e of t)
						if ("" !== e) {
							if ("string" != typeof e && !(e instanceof g && e.#r === this)) throw new Error("invalid part: " + e);
							this.#i.push(e)
						}
				}
				toJSON() {
					const t = null === this.type ? this.#i.slice().map((t => "string" == typeof t ? t : t.toJSON())) : [this.type, ...this.#i.map((t => t.toJSON()))];
					return this.isStart() && !this.type && t.unshift([]), this.isEnd() && (this === this.#t || this.#t.#a && "!" === this.#r?.type) && t.push({}), t
				}
				isStart() {
					if (this.#t === this) return !0;
					if (!this.#r?.isStart()) return !1;
					if (0 === this.#n) return !0;
					const t = this.#r;
					for (let e = 0; e < this.#n; e++) {
						const s = t.#i[e];
						if (!(s instanceof g && "!" === s.type)) return !1
					}
					return !0
				}
				isEnd() {
					if (this.#t === this) return !0;
					if ("!" === this.#r?.type) return !0;
					if (!this.#r?.isEnd()) return !1;
					if (!this.type) return this.#r?.isEnd();
					const t = this.#r ? this.#r.#i.length : 0;
					return this.#n === t - 1
				}
				copyIn(t) {
					"string" == typeof t ? this.push(t) : this.push(t.clone(this))
				}
				clone(t) {
					const e = new g(this.type, t);
					for (const t of this.#i) e.copyIn(t);
					return e
				}
				static #u(t, e, s, i) {
					let r = !1,
						n = !1,
						a = -1,
						h = !1;
					if (null === e.type) {
						let l = s,
							p = "";
						for (; l < t.length;) {
							const s = t.charAt(l++);
							if (r || "\\" === s) r = !r, p += s;
							else if (n) l === a + 1 ? "^" !== s && "!" !== s || (h = !0) : "]" !== s || l === a + 2 && h || (n = !1), p += s;
							else if ("[" !== s)
								if (i.noext || !o(s) || "(" !== t.charAt(l)) p += s;
								else {
									e.push(p), p = "";
									const r = new g(s, e);
									l = g.#u(t, r, l, i), e.push(r)
								}
							else n = !0, a = l, h = !1, p += s
						}
						return e.push(p), l
					}
					let l = s + 1,
						p = new g(null, e);
					const c = [];
					let u = "";
					for (; l < t.length;) {
						const s = t.charAt(l++);
						if (r || "\\" === s) r = !r, u += s;
						else if (n) l === a + 1 ? "^" !== s && "!" !== s || (h = !0) : "]" !== s || l === a + 2 && h || (n = !1), u += s;
						else if ("[" !== s)
							if (o(s) && "(" === t.charAt(l)) {
								p.push(u), u = "";
								const e = new g(s, p);
								p.push(e), l = g.#u(t, e, l, i)
							} else if ("|" !== s) {
								if (")" === s) return "" === u && 0 === e.#i.length && (e.#p = !0), p.push(u), u = "", e.push(...c, p), l;
								u += s
							} else p.push(u), u = "", c.push(p), p = new g(null, e);
						else n = !0, a = l, h = !1, u += s
					}
					return e.type = null, e.#e = void 0, e.#i = [t.substring(s - 1)], l
				}
				static fromGlob(t, e = {}) {
					const s = new g(null, void 0, e);
					return g.#u(t, s, 0, e), s
				}
				toMMPattern() {
					if (this !== this.#t) return this.#t.toMMPattern();
					const t = this.toString(),
						[e, s, i, r] = this.toRegExpSource();
					if (!(i || this.#e || this.#h.nocase && !this.#h.nocaseMagicOnly && t.toUpperCase() !== t.toLowerCase())) return s;
					const n = (this.#h.nocase ? "i" : "") + (r ? "u" : "");
					return Object.assign(new RegExp(`^${e}$`, n), {
						_src: e,
						_glob: t
					})
				}
				get options() {
					return this.#h
				}
				toRegExpSource(t) {
					const e = t ?? !!this.#h.dot;
					if (this.#t === this && this.#c(), !this.type) {
						const s = this.isStart() && this.isEnd(),
							i = this.#i.map((e => {
								const [i, r, n, o] = "string" == typeof e ? g.#f(e, this.#e, s) : e.toRegExpSource(t);
								return this.#e = this.#e || n, this.#s = this.#s || o, i
							})).join("");
						let n = "";
						if (this.isStart() && "string" == typeof this.#i[0] && (1 !== this.#i.length || !l.has(this.#i[0]))) {
							const s = h,
								r = e && s.has(i.charAt(0)) || i.startsWith("\\.") && s.has(i.charAt(2)) || i.startsWith("\\.\\.") && s.has(i.charAt(4)),
								o = !e && !t && s.has(i.charAt(0));
							n = r ? "(?!(?:^|/)\\.\\.?(?:$|/))" : o ? a : ""
						}
						let o = "";
						return this.isEnd() && this.#t.#a && "!" === this.#r?.type && (o = "(?:$|\\/)"), [n + i + o, (0, r.unescape)(i), this.#e = !!this.#e, this.#s]
					}
					const s = "*" === this.type || "+" === this.type,
						i = "!" === this.type ? "(?:(?!(?:" : "(?:";
					let n = this.#g(e);
					if (this.isStart() && this.isEnd() && !n && "!" !== this.type) {
						const t = this.toString();
						return this.#i = [t], this.type = null, this.#e = void 0, [t, (0, r.unescape)(this.toString()), !1, !1]
					}
					let o = !s || t || e ? "" : this.#g(!0);
					o === n && (o = ""), o && (n = `(?:${n})(?:${o})*?`);
					let p = "";
					return p = "!" === this.type && this.#p ? (this.isStart() && !e ? a : "") + f : i + n + ("!" === this.type ? "))" + (!this.isStart() || e || t ? "" : a) + u + ")" : "@" === this.type ? ")" : "?" === this.type ? ")?" : "+" === this.type && o ? ")" : "*" === this.type && o ? ")?" : `)${this.type}`), [p, (0, r.unescape)(n), this.#e = !!this.#e, this.#s]
				}
				#g(t) {
					return this.#i.map((e => {
						if ("string" == typeof e) throw new Error("string type in extglob ast??");
						const [s, i, r, n] = e.toRegExpSource(t);
						return this.#s = this.#s || n, s
					})).filter((t => !(this.isStart() && this.isEnd() && !t))).join("|")
				}
				static #f(t, e, s = !1) {
					let n = !1,
						o = "",
						a = !1;
					for (let r = 0; r < t.length; r++) {
						const h = t.charAt(r);
						if (n) n = !1, o += (p.has(h) ? "\\" : "") + h;
						else if ("\\" !== h) {
							if ("[" === h) {
								const [s, n, h, l] = (0, i.parseClass)(t, r);
								if (h) {
									o += s, a = a || n, r += h - 1, e = e || l;
									continue
								}
							}
							"*" !== h ? "?" !== h ? o += h.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") : (o += c, e = !0) : (o += s && "*" === t ? f : u, e = !0)
						} else r === t.length - 1 ? o += "\\\\" : n = !0
					}
					return [o, (0, r.unescape)(t), !!e, a]
				}
			}
			e.AST = g
		},
		802: (t, e) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.parseClass = void 0;
			const s = {
				"[:alnum:]": ["\\p{L}\\p{Nl}\\p{Nd}", !0],
				"[:alpha:]": ["\\p{L}\\p{Nl}", !0],
				"[:ascii:]": ["\\x00-\\x7f", !1],
				"[:blank:]": ["\\p{Zs}\\t", !0],
				"[:cntrl:]": ["\\p{Cc}", !0],
				"[:digit:]": ["\\p{Nd}", !0],
				"[:graph:]": ["\\p{Z}\\p{C}", !0, !0],
				"[:lower:]": ["\\p{Ll}", !0],
				"[:print:]": ["\\p{C}", !0],
				"[:punct:]": ["\\p{P}", !0],
				"[:space:]": ["\\p{Z}\\t\\r\\n\\v\\f", !0],
				"[:upper:]": ["\\p{Lu}", !0],
				"[:word:]": ["\\p{L}\\p{Nl}\\p{Nd}\\p{Pc}", !0],
				"[:xdigit:]": ["A-Fa-f0-9", !1]
			},
				i = t => t.replace(/[[\]\\-]/g, "\\$&"),
				r = t => t.join("");
			e.parseClass = (t, e) => {
				const n = e;
				if ("[" !== t.charAt(n)) throw new Error("not in a brace expression");
				const o = [],
					a = [];
				let h = n + 1,
					l = !1,
					p = !1,
					c = !1,
					u = !1,
					f = n,
					g = "";
				t: for (; h < t.length;) {
					const e = t.charAt(h);
					if ("!" !== e && "^" !== e || h !== n + 1) {
						if ("]" === e && l && !c) {
							f = h + 1;
							break
						}
						if (l = !0, "\\" !== e || c) {
							if ("[" === e && !c)
								for (const [e, [i, r, l]] of Object.entries(s))
									if (t.startsWith(e, h)) {
										if (g) return ["$.", !1, t.length - n, !0];
										h += e.length, l ? a.push(i) : o.push(i), p = p || r;
										continue t
									} c = !1, g ? (e > g ? o.push(i(g) + "-" + i(e)) : e === g && o.push(i(e)), g = "", h++) : t.startsWith("-]", h + 1) ? (o.push(i(e + "-")), h += 2) : t.startsWith("-", h + 1) ? (g = e, h += 2) : (o.push(i(e)), h++)
						} else c = !0, h++
					} else u = !0, h++
				}
				if (f < h) return ["", !1, 0, !1];
				if (!o.length && !a.length) return ["$.", !1, t.length - n, !0];
				if (0 === a.length && 1 === o.length && /^\\?.$/.test(o[0]) && !u) {
					return [(d = 2 === o[0].length ? o[0].slice(-1) : o[0], d.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")), !1, f - n, !1]
				}
				var d;
				const m = "[" + (u ? "^" : "") + r(o) + "]",
					b = "[" + (u ? "" : "^") + r(a) + "]";
				return [o.length && a.length ? "(" + m + "|" + b + ")" : o.length ? m : b, p, f - n, !0]
			}
		},
		242: (t, e) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.escape = void 0, e.escape = (t, {
				windowsPathsNoEscape: e = !1
			} = {}) => e ? t.replace(/[?*()[\]]/g, "[$&]") : t.replace(/[?*()[\]\\]/g, "\\$&")
		},
		761: (t, e, s) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.unescape = e.escape = e.AST = e.Minimatch = e.match = e.makeRe = e.braceExpand = e.defaults = e.filter = e.GLOBSTAR = e.sep = e.minimatch = void 0;
			const i = s(910),
				r = s(402),
				n = s(698),
				o = s(242),
				a = s(157);
			e.minimatch = (t, e, s = {}) => ((0, r.assertValidPattern)(e), !(!s.nocomment && "#" === e.charAt(0)) && new C(e, s).match(t));
			const h = /^\*+([^+@!?\*\[\(]*)$/,
				l = t => e => !e.startsWith(".") && e.endsWith(t),
				p = t => e => e.endsWith(t),
				c = t => (t = t.toLowerCase(), e => !e.startsWith(".") && e.toLowerCase().endsWith(t)),
				u = t => (t = t.toLowerCase(), e => e.toLowerCase().endsWith(t)),
				f = /^\*+\.\*+$/,
				g = t => !t.startsWith(".") && t.includes("."),
				d = t => "." !== t && ".." !== t && t.includes("."),
				m = /^\.\*+$/,
				b = t => "." !== t && ".." !== t && t.startsWith("."),
				w = /^\*+$/,
				y = t => 0 !== t.length && !t.startsWith("."),
				S = t => 0 !== t.length && "." !== t && ".." !== t,
				v = /^\?+([^+@!?\*\[\(]*)?$/,
				x = ([t, e = ""]) => {
					const s = E([t]);
					return e ? (e = e.toLowerCase(), t => s(t) && t.toLowerCase().endsWith(e)) : s
				},
				O = ([t, e = ""]) => {
					const s = P([t]);
					return e ? (e = e.toLowerCase(), t => s(t) && t.toLowerCase().endsWith(e)) : s
				},
				M = ([t, e = ""]) => {
					const s = P([t]);
					return e ? t => s(t) && t.endsWith(e) : s
				},
				A = ([t, e = ""]) => {
					const s = E([t]);
					return e ? t => s(t) && t.endsWith(e) : s
				},
				E = ([t]) => {
					const e = t.length;
					return t => t.length === e && !t.startsWith(".")
				},
				P = ([t]) => {
					const e = t.length;
					return t => t.length === e && "." !== t && ".." !== t
				},
				R = "object" == typeof process && process ? "object" == typeof process.env && process.env && process.env.__MINIMATCH_TESTING_PLATFORM__ || process.platform : "posix";
			e.sep = "win32" === R ? "\\" : "/", e.minimatch.sep = e.sep, e.GLOBSTAR = Symbol("globstar **"), e.minimatch.GLOBSTAR = e.GLOBSTAR, e.filter = (t, s = {}) => i => (0, e.minimatch)(i, t, s), e.minimatch.filter = e.filter;
			const T = (t, e = {}) => Object.assign({}, t, e);
			e.defaults = t => {
				if (!t || "object" != typeof t || !Object.keys(t).length) return e.minimatch;
				const s = e.minimatch;
				return Object.assign(((e, i, r = {}) => s(e, i, T(t, r))), {
					Minimatch: class extends s.Minimatch {
						constructor(e, s = {}) {
							super(e, T(t, s))
						}
						static defaults(e) {
							return s.defaults(T(t, e)).Minimatch
						}
					},
					AST: class extends s.AST {
						constructor(e, s, i = {}) {
							super(e, s, T(t, i))
						}
						static fromGlob(e, i = {}) {
							return s.AST.fromGlob(e, T(t, i))
						}
					},
					unescape: (e, i = {}) => s.unescape(e, T(t, i)),
					escape: (e, i = {}) => s.escape(e, T(t, i)),
					filter: (e, i = {}) => s.filter(e, T(t, i)),
					defaults: e => s.defaults(T(t, e)),
					makeRe: (e, i = {}) => s.makeRe(e, T(t, i)),
					braceExpand: (e, i = {}) => s.braceExpand(e, T(t, i)),
					match: (e, i, r = {}) => s.match(e, i, T(t, r)),
					sep: s.sep,
					GLOBSTAR: e.GLOBSTAR
				})
			}, e.minimatch.defaults = e.defaults, e.braceExpand = (t, e = {}) => ((0, r.assertValidPattern)(t), e.nobrace || !/\{(?:(?!\{).)*\}/.test(t) ? [t] : (0, i.expand)(t)), e.minimatch.braceExpand = e.braceExpand, e.makeRe = (t, e = {}) => new C(t, e).makeRe(), e.minimatch.makeRe = e.makeRe, e.match = (t, e, s = {}) => {
				const i = new C(e, s);
				return t = t.filter((t => i.match(t))), i.options.nonull && !t.length && t.push(e), t
			}, e.minimatch.match = e.match;
			const $ = /[?*]|[+@!]\(.*?\)|\[|\]/;
			class C {
				options;
				set;
				pattern;
				windowsPathsNoEscape;
				nonegate;
				negate;
				comment;
				empty;
				preserveMultipleSlashes;
				partial;
				globSet;
				globParts;
				nocase;
				isWindows;
				platform;
				windowsNoMagicRoot;
				regexp;
				constructor(t, e = {}) {
					(0, r.assertValidPattern)(t), e = e || {}, this.options = e, this.pattern = t, this.platform = e.platform || R, this.isWindows = "win32" === this.platform, this.windowsPathsNoEscape = !!e.windowsPathsNoEscape || !1 === e.allowWindowsEscape, this.windowsPathsNoEscape && (this.pattern = this.pattern.replace(/\\/g, "/")), this.preserveMultipleSlashes = !!e.preserveMultipleSlashes, this.regexp = null, this.negate = !1, this.nonegate = !!e.nonegate, this.comment = !1, this.empty = !1, this.partial = !!e.partial, this.nocase = !!this.options.nocase, this.windowsNoMagicRoot = void 0 !== e.windowsNoMagicRoot ? e.windowsNoMagicRoot : !(!this.isWindows || !this.nocase), this.globSet = [], this.globParts = [], this.set = [], this.make()
				}
				hasMagic() {
					if (this.options.magicalBraces && this.set.length > 1) return !0;
					for (const t of this.set)
						for (const e of t)
							if ("string" != typeof e) return !0;
					return !1
				}
				debug(...t) { }
				make() {
					const t = this.pattern,
						e = this.options;
					if (!e.nocomment && "#" === t.charAt(0)) return void (this.comment = !0);
					if (!t) return void (this.empty = !0);
					this.parseNegate(), this.globSet = [...new Set(this.braceExpand())], e.debug && (this.debug = (...t) => console.error(...t)), this.debug(this.pattern, this.globSet);
					const s = this.globSet.map((t => this.slashSplit(t)));
					this.globParts = this.preprocess(s), this.debug(this.pattern, this.globParts);
					let i = this.globParts.map(((t, e, s) => {
						if (this.isWindows && this.windowsNoMagicRoot) {
							const e = !("" !== t[0] || "" !== t[1] || "?" !== t[2] && $.test(t[2]) || $.test(t[3])),
								s = /^[a-z]:/i.test(t[0]);
							if (e) return [...t.slice(0, 4), ...t.slice(4).map((t => this.parse(t)))];
							if (s) return [t[0], ...t.slice(1).map((t => this.parse(t)))]
						}
						return t.map((t => this.parse(t)))
					}));
					if (this.debug(this.pattern, i), this.set = i.filter((t => -1 === t.indexOf(!1))), this.isWindows)
						for (let t = 0; t < this.set.length; t++) {
							const e = this.set[t];
							"" === e[0] && "" === e[1] && "?" === this.globParts[t][2] && "string" == typeof e[3] && /^[a-z]:$/i.test(e[3]) && (e[2] = "?")
						}
					this.debug(this.pattern, this.set)
				}
				preprocess(t) {
					if (this.options.noglobstar)
						for (let e = 0; e < t.length; e++)
							for (let s = 0; s < t[e].length; s++) "**" === t[e][s] && (t[e][s] = "*");
					const {
						optimizationLevel: e = 1
					} = this.options;
					return e >= 2 ? (t = this.firstPhasePreProcess(t), t = this.secondPhasePreProcess(t)) : t = e >= 1 ? this.levelOneOptimize(t) : this.adjascentGlobstarOptimize(t), t
				}
				adjascentGlobstarOptimize(t) {
					return t.map((t => {
						let e = -1;
						for (; - 1 !== (e = t.indexOf("**", e + 1));) {
							let s = e;
							for (;
								"**" === t[s + 1];) s++;
							s !== e && t.splice(e, s - e)
						}
						return t
					}))
				}
				levelOneOptimize(t) {
					return t.map((t => 0 === (t = t.reduce(((t, e) => {
						const s = t[t.length - 1];
						return "**" === e && "**" === s ? t : ".." === e && s && ".." !== s && "." !== s && "**" !== s ? (t.pop(), t) : (t.push(e), t)
					}), [])).length ? [""] : t))
				}
				levelTwoFileOptimize(t) {
					Array.isArray(t) || (t = this.slashSplit(t));
					let e = !1;
					do {
						if (e = !1, !this.preserveMultipleSlashes) {
							for (let s = 1; s < t.length - 1; s++) {
								const i = t[s];
								1 === s && "" === i && "" === t[0] || "." !== i && "" !== i || (e = !0, t.splice(s, 1), s--)
							}
							"." !== t[0] || 2 !== t.length || "." !== t[1] && "" !== t[1] || (e = !0, t.pop())
						}
						let s = 0;
						for (; - 1 !== (s = t.indexOf("..", s + 1));) {
							const i = t[s - 1];
							i && "." !== i && ".." !== i && "**" !== i && (e = !0, t.splice(s - 1, 2), s -= 2)
						}
					} while (e);
					return 0 === t.length ? [""] : t
				}
				firstPhasePreProcess(t) {
					let e = !1;
					do {
						e = !1;
						for (let s of t) {
							let i = -1;
							for (; - 1 !== (i = s.indexOf("**", i + 1));) {
								let r = i;
								for (;
									"**" === s[r + 1];) r++;
								r > i && s.splice(i + 1, r - i);
								let n = s[i + 1];
								const o = s[i + 2],
									a = s[i + 3];
								if (".." !== n) continue;
								if (!o || "." === o || ".." === o || !a || "." === a || ".." === a) continue;
								e = !0, s.splice(i, 1);
								const h = s.slice(0);
								h[i] = "**", t.push(h), i--
							}
							if (!this.preserveMultipleSlashes) {
								for (let t = 1; t < s.length - 1; t++) {
									const i = s[t];
									1 === t && "" === i && "" === s[0] || "." !== i && "" !== i || (e = !0, s.splice(t, 1), t--)
								}
								"." !== s[0] || 2 !== s.length || "." !== s[1] && "" !== s[1] || (e = !0, s.pop())
							}
							let r = 0;
							for (; - 1 !== (r = s.indexOf("..", r + 1));) {
								const t = s[r - 1];
								if (t && "." !== t && ".." !== t && "**" !== t) {
									e = !0;
									const t = 1 === r && "**" === s[r + 1] ? ["."] : [];
									s.splice(r - 1, 2, ...t), 0 === s.length && s.push(""), r -= 2
								}
							}
						}
					} while (e);
					return t
				}
				secondPhasePreProcess(t) {
					for (let e = 0; e < t.length - 1; e++)
						for (let s = e + 1; s < t.length; s++) {
							const i = this.partsMatch(t[e], t[s], !this.preserveMultipleSlashes);
							if (i) {
								t[e] = [], t[s] = i;
								break
							}
						}
					return t.filter((t => t.length))
				}
				partsMatch(t, e, s = !1) {
					let i = 0,
						r = 0,
						n = [],
						o = "";
					for (; i < t.length && r < e.length;)
						if (t[i] === e[r]) n.push("b" === o ? e[r] : t[i]), i++, r++;
						else if (s && "**" === t[i] && e[r] === t[i + 1]) n.push(t[i]), i++;
						else if (s && "**" === e[r] && t[i] === e[r + 1]) n.push(e[r]), r++;
						else if ("*" !== t[i] || !e[r] || !this.options.dot && e[r].startsWith(".") || "**" === e[r]) {
							if ("*" !== e[r] || !t[i] || !this.options.dot && t[i].startsWith(".") || "**" === t[i]) return !1;
							if ("a" === o) return !1;
							o = "b", n.push(e[r]), i++, r++
						} else {
							if ("b" === o) return !1;
							o = "a", n.push(t[i]), i++, r++
						}
					return t.length === e.length && n
				}
				parseNegate() {
					if (this.nonegate) return;
					const t = this.pattern;
					let e = !1,
						s = 0;
					for (let i = 0; i < t.length && "!" === t.charAt(i); i++) e = !e, s++;
					s && (this.pattern = t.slice(s)), this.negate = e
				}
				matchOne(t, s, i = !1) {
					const r = this.options;
					if (this.isWindows) {
						const e = "string" == typeof t[0] && /^[a-z]:$/i.test(t[0]),
							i = !e && "" === t[0] && "" === t[1] && "?" === t[2] && /^[a-z]:$/i.test(t[3]),
							r = "string" == typeof s[0] && /^[a-z]:$/i.test(s[0]),
							n = i ? 3 : e ? 0 : void 0,
							o = !r && "" === s[0] && "" === s[1] && "?" === s[2] && "string" == typeof s[3] && /^[a-z]:$/i.test(s[3]) ? 3 : r ? 0 : void 0;
						if ("number" == typeof n && "number" == typeof o) {
							const [e, i] = [t[n], s[o]];
							e.toLowerCase() === i.toLowerCase() && (s[o] = e, o > n ? s = s.slice(o) : n > o && (t = t.slice(n)))
						}
					}
					const {
						optimizationLevel: n = 1
					} = this.options;
					n >= 2 && (t = this.levelTwoFileOptimize(t)), this.debug("matchOne", this, {
						file: t,
						pattern: s
					}), this.debug("matchOne", t.length, s.length);
					for (var o = 0, a = 0, h = t.length, l = s.length; o < h && a < l; o++, a++) {
						this.debug("matchOne loop");
						var p = s[a],
							c = t[o];
						if (this.debug(s, p, c), !1 === p) return !1;
						if (p === e.GLOBSTAR) {
							this.debug("GLOBSTAR", [s, p, c]);
							var u = o,
								f = a + 1;
							if (f === l) {
								for (this.debug("** at the end"); o < h; o++)
									if ("." === t[o] || ".." === t[o] || !r.dot && "." === t[o].charAt(0)) return !1;
								return !0
							}
							for (; u < h;) {
								var g = t[u];
								if (this.debug("\nglobstar while", t, u, s, f, g), this.matchOne(t.slice(u), s.slice(f), i)) return this.debug("globstar found match!", u, h, g), !0;
								if ("." === g || ".." === g || !r.dot && "." === g.charAt(0)) {
									this.debug("dot detected!", t, u, s, f);
									break
								}
								this.debug("globstar swallow a segment, and continue"), u++
							}
							return !(!i || (this.debug("\n>>> no match, partial?", t, u, s, f), u !== h))
						}
						let n;
						if ("string" == typeof p ? (n = c === p, this.debug("string match", p, c, n)) : (n = p.test(c), this.debug("pattern match", p, c, n)), !n) return !1
					}
					if (o === h && a === l) return !0;
					if (o === h) return i;
					if (a === l) return o === h - 1 && "" === t[o];
					throw new Error("wtf?")
				}
				braceExpand() {
					return (0, e.braceExpand)(this.pattern, this.options)
				}
				parse(t) {
					(0, r.assertValidPattern)(t);
					const s = this.options;
					if ("**" === t) return e.GLOBSTAR;
					if ("" === t) return "";
					let i, o = null;
					(i = t.match(w)) ? o = s.dot ? S : y : (i = t.match(h)) ? o = (s.nocase ? s.dot ? u : c : s.dot ? p : l)(i[1]) : (i = t.match(v)) ? o = (s.nocase ? s.dot ? O : x : s.dot ? M : A)(i) : (i = t.match(f)) ? o = s.dot ? d : g : (i = t.match(m)) && (o = b);
					const a = n.AST.fromGlob(t, this.options).toMMPattern();
					return o && "object" == typeof a && Reflect.defineProperty(a, "test", {
						value: o
					}), a
				}
				makeRe() {
					if (this.regexp || !1 === this.regexp) return this.regexp;
					const t = this.set;
					if (!t.length) return this.regexp = !1, this.regexp;
					const s = this.options,
						i = s.noglobstar ? "[^/]*?" : s.dot ? "(?:(?!(?:\\/|^)(?:\\.{1,2})($|\\/)).)*?" : "(?:(?!(?:\\/|^)\\.).)*?",
						r = new Set(s.nocase ? ["i"] : []);
					let n = t.map((t => {
						const s = t.map((t => {
							if (t instanceof RegExp)
								for (const e of t.flags.split("")) r.add(e);
							return "string" == typeof t ? t.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") : t === e.GLOBSTAR ? e.GLOBSTAR : t._src
						}));
						return s.forEach(((t, r) => {
							const n = s[r + 1],
								o = s[r - 1];
							t === e.GLOBSTAR && o !== e.GLOBSTAR && (void 0 === o ? void 0 !== n && n !== e.GLOBSTAR ? s[r + 1] = "(?:\\/|" + i + "\\/)?" + n : s[r] = i : void 0 === n ? s[r - 1] = o + "(?:\\/|" + i + ")?" : n !== e.GLOBSTAR && (s[r - 1] = o + "(?:\\/|\\/" + i + "\\/)" + n, s[r + 1] = e.GLOBSTAR))
						})), s.filter((t => t !== e.GLOBSTAR)).join("/")
					})).join("|");
					const [o, a] = t.length > 1 ? ["(?:", ")"] : ["", ""];
					n = "^" + o + n + a + "$", this.negate && (n = "^(?!" + n + ").+$");
					try {
						this.regexp = new RegExp(n, [...r].join(""))
					} catch (t) {
						this.regexp = !1
					}
					return this.regexp
				}
				slashSplit(t) {
					return this.preserveMultipleSlashes ? t.split("/") : this.isWindows && /^\/\/[^\/]+/.test(t) ? ["", ...t.split(/\/+/)] : t.split(/\/+/)
				}
				match(t, e = this.partial) {
					if (this.debug("match", t, this.pattern), this.comment) return !1;
					if (this.empty) return "" === t;
					if ("/" === t && e) return !0;
					const s = this.options;
					this.isWindows && (t = t.split("\\").join("/"));
					const i = this.slashSplit(t);
					this.debug(this.pattern, "split", i);
					const r = this.set;
					this.debug(this.pattern, "set", r);
					let n = i[i.length - 1];
					if (!n)
						for (let t = i.length - 2; !n && t >= 0; t--) n = i[t];
					for (let t = 0; t < r.length; t++) {
						const o = r[t];
						let a = i;
						if (s.matchBase && 1 === o.length && (a = [n]), this.matchOne(a, o, e)) return !!s.flipNegate || !this.negate
					}
					return !s.flipNegate && this.negate
				}
				static defaults(t) {
					return e.minimatch.defaults(t).Minimatch
				}
			}
			e.Minimatch = C;
			var L = s(698);
			Object.defineProperty(e, "AST", {
				enumerable: !0,
				get: function () {
					return L.AST
				}
			});
			var j = s(242);
			Object.defineProperty(e, "escape", {
				enumerable: !0,
				get: function () {
					return j.escape
				}
			});
			var N = s(157);
			Object.defineProperty(e, "unescape", {
				enumerable: !0,
				get: function () {
					return N.unescape
				}
			}), e.minimatch.AST = n.AST, e.minimatch.Minimatch = C, e.minimatch.escape = o.escape, e.minimatch.unescape = a.unescape
		},
		157: (t, e) => {
			Object.defineProperty(e, "__esModule", {
				value: !0
			}), e.unescape = void 0, e.unescape = (t, {
				windowsPathsNoEscape: e = !1
			} = {}) => e ? t.replace(/\[([^\/\\])\]/g, "$1") : t.replace(/((?!\\).|^)\[([^\/\\])\]/g, "$1$2").replace(/\\([^\/])/g, "$1")
		}
	},
		e = {};

	function s(i) {
		var r = e[i];
		if (void 0 !== r) return r.exports;
		var n = e[i] = {
			exports: {}
		};
		return t[i](n, n.exports, s), n.exports
	}
	var i = {};
	(() => {
		var t = i;
		Object.defineProperty(t, "__esModule", {
			value: !0
		}), t.activate = void 0;
		const e = s(496),
			r = s(17),
			n = s(761),
			o = {
				blue: "terminal.ansiBlue",
				magenta: "terminal.ansiBrightMagenta",
				red: "terminal.ansiBrightRed",
				cyan: "terminal.ansiBrightCyan",
				green: "terminal.ansiBrightGreen",
				yellow: "terminal.ansiBrightYellow",
				custom1: "folderPathColor.custom1",
				animation: "folderPathColor.animation",
				dark_misc: "folderPathColor.dark_misc",
				utils: "folderPathColor.utils",
				custom5: "folderPathColor.custom5",
				white_: "folderPathColor.white_",
				custom7: "folderPathColor.custom7",
				model: "folderPathColor.model",
				states_blue: "folderPathColor.states_blue",
				custom10: "folderPathColor.custom10",
				custom11: "folderPathColor.custom11",
				custom12: "folderPathColor.custom12",
				custom13: "folderPathColor.custom13",
			};
		class a {
			constructFolders() {
				this.folders = [];
				const t = e.workspace.getConfiguration("folder-path-color").get("folders") || [],
					s = Object.keys(o).filter((e => !t.find((t => t.color === e))));
				let i = 0;
				for (const e of t) Object.keys(o)[i] || (i = 0), this.folders.push({
					path: e.path,
					color: e.color || s[i] || Object.keys(o)[i],
					symbol: e.symbol,
					tooltip: e.tooltip
				}), i++
			}
			constructor() {
				this._onDidChangeFileDecorations = new e.EventEmitter, this.onDidChangeFileDecorations = this._onDidChangeFileDecorations.event, this.folders = [], e.workspace.onDidChangeConfiguration((t => {
					t.affectsConfiguration("folder-path-color.folders") && (this.constructFolders(), this._onDidChangeFileDecorations.fire(void 0))
				})), this.constructFolders()
			}
			provideFileDecoration(t, s) {
				if (e.workspace.workspaceFolders) {
					const s = e.workspace.workspaceFolders.map((t => t.uri.path));
					let i = 0;
					for (const a of this.folders) {
						let h = o[a.color];
						if (s.some((e => {
							const s = t.path.replace(/\\/g, "/"),
								i = r.join(e, a.path).replace(/\\/g, "/");
							if (/[\*\?\[\]]/.test(a.path)) {
								const s = r.relative(e, t.fsPath).replace(/\\/g, "/");
								return (0, n.minimatch)(s, a.path, {
									matchBase: !0
								})
							}
							return s.includes(i)
						}))) return new e.FileDecoration(a.symbol, a.tooltip, new e.ThemeColor(h));
						i++
					}
				}
			}
		}
		t.activate = function (t) {
			const s = new a;
			t.subscriptions.push(e.window.registerFileDecorationProvider(s))
		}
	})(), module.exports = i
})();