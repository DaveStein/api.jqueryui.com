<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" omit-xml-declaration="yes"/>

<xsl:template match="/">
	<script>{
		"title":
			<xsl:call-template name="escape-string">
				<xsl:with-param name="s" select="//entry/@name"/>
			</xsl:call-template>,
		"excerpt":
			<xsl:call-template name="escape-string">
				<xsl:with-param name="s" select="//entry[1]/desc/text()|//entry[1]/desc/*"/>
			</xsl:call-template>,
		"termSlugs": {
			"category": [
				<xsl:for-each select="//entry/category">
					<xsl:if test="position() &gt; 1"><xsl:text>,</xsl:text></xsl:if>
					<xsl:text>"</xsl:text>
					<xsl:value-of select="@slug"/>
					<xsl:text>"</xsl:text>
				</xsl:for-each>
			]
		}
	}</script>

	<xsl:if test="count(//entry) &gt; 1">
		<xsl:call-template name="toc"/>
	</xsl:if>

	<xsl:for-each select="//entry">
		<xsl:variable name="entry-name" select="@name"/>
		<xsl:variable name="entry-name-trans" select="translate($entry-name,'$., ()/{}','s---')"/>
		<xsl:variable name="entry-type" select="@type"/>
		<xsl:variable name="entry-index" select="position()"/>
		<xsl:variable name="entry-pos" select="concat($entry-name-trans,$entry-index)"/>
		<xsl:variable name="number-examples" select="count(example)"/>

		<xsl:if test="./added">
			<span class="versionAdded">version added: <xsl:value-of select="added"/></span>
		</xsl:if>

		<article>
			<xsl:attribute name="id">
				<xsl:value-of select="$entry-pos"/>
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:value-of select="concat('entry ', $entry-type)"/>
			</xsl:attribute>

			<xsl:call-template name="entry-title"/>

			<xsl:copy-of select="desc/node()"/>

			<nav>
				<ul>
					<xsl:if test="longdesc">
						<li><a href="#overview">Overview</a></li>
					</xsl:if>
					<xsl:if test="options">
						<li>
							<a href="#options">Options</a>
							<ul>
								<xsl:for-each select="options/option">
									<li>
										<a href="#option-{@name}">
											<xsl:value-of select="@name"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:if>
					<xsl:if test="methods">
						<li>
							<a href="#methods">Methods</a>
							<ul>
								<xsl:for-each select="methods/method">
									<li>
										<a href="#method-{@name}">
											<xsl:value-of select="@name"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:if>
					<xsl:if test="events">
						<li>
							<a href="#events">Events</a>
							<ul>
								<xsl:for-each select="events/event">
									<li>
										<a href="#event-{@name}">
											<xsl:value-of select="@name"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:if>
					<xsl:if test="example">
						<li><a href="#examples">Examples</a></li>
					</xsl:if>
				</ul>
			</nav>
			<xsl:if test="longdesc">
				<section id="overview">
					<header>
						<h2 class="underline">Overview</h2>
					</header>
					<p>
						<xsl:copy-of select="longdesc/node()"/>
					</p>
				</section>
			</xsl:if>
			<xsl:if test="options">
				<section id="options">
					<header>
						<h2 class="underline">Options</h2>
					</header>
					<ul>
						<xsl:for-each select="options/option">
							<xsl:variable name="number-option-examples" select="count(example)" />
							<li id="option-{@name}">
								<h3>
									<xsl:value-of select="@name"/>
								</h3>
								<p>
									<strong>Type: </strong>
									<xsl:call-template name="render-types" />
								</p>
								<p>
									<strong>Default: </strong>
									<xsl:value-of select="@default"/>
								</p>
								<div>
									<xsl:copy-of select="desc/node()"/>
								</div>
								<xsl:if test="type/desc">
									Multiple types supported:
									<ul>
										<xsl:for-each select="type/desc">
											<li>
												<strong><xsl:value-of select="../@name"/></strong>: <xsl:copy-of select="node()"/>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:if>
								<xsl:apply-templates select="example">
									<xsl:with-param name="number-examples" select="$number-option-examples" />
								</xsl:apply-templates>
							</li>
						</xsl:for-each>
					</ul>
				</section>
			</xsl:if>
			<xsl:if test="methods">
				<section id="methods">
					<header>
						<h2 class="underline">Methods</h2>
					</header>
					<ul>
						<xsl:for-each select="methods/method">
							<li id="method-{@name}">
								<h3><xsl:value-of select="@name"/>( <xsl:for-each select="argument"><xsl:if test="position() &gt; 1">, </xsl:if><xsl:if test="@optional">[</xsl:if><xsl:value-of select="@name"/><xsl:if test="@optional">]</xsl:if></xsl:for-each> )</h3>
								<div>
									<xsl:apply-templates select="desc">
										<xsl:with-param name="entry-name" select="$entry-name"/>
									</xsl:apply-templates>
								</div>
								<xsl:call-template name="arguments"/>
							</li>
						</xsl:for-each>
					</ul>
				</section>
			</xsl:if>
			<xsl:if test="events">
				<section id="events">
					<header>
						<h2 class="underline">Events</h2>
					</header>
					<ul>
						<xsl:for-each select="events/event">
							<li id="event-{@name}">
								<h3><xsl:value-of select="@name"/>( <xsl:for-each select="argument"><xsl:if test="position() &gt; 1">, </xsl:if><xsl:value-of select="@name"/></xsl:for-each> )</h3>
								<div>
									<xsl:apply-templates select="desc">
										<xsl:with-param name="entry-name" select="$entry-name"/>
									</xsl:apply-templates>
								</div>
								<xsl:call-template name="arguments"/>
							</li>
						</xsl:for-each>
					</ul>
				</section>
			</xsl:if>
			<xsl:if test="example">
				<section class="entry-examples">
					<xsl:attribute name="id">
						<xsl:text>entry-examples</xsl:text>
						<xsl:if test="$entry-index &gt; 1">
							<xsl:text>-</xsl:text><xsl:value-of select="$entry-index - 1"/>
						</xsl:if>
					</xsl:attribute>

					<header>
						<h2 class="underline">Example<xsl:if test="$number-examples &gt; 1">s</xsl:if></h2>
					</header>

					<xsl:apply-templates select="example">
						<xsl:with-param name="entry-index" select="$entry-index"/>
						<xsl:with-param name="number-examples" select="$number-examples"/>
					</xsl:apply-templates>
				</section>
			</xsl:if>
		</article>
	</xsl:for-each>
</xsl:template>

<xsl:template name="entry-title">
	<xsl:param name="entry-type" select="@type"/>
	<xsl:param name="entry-name" select="@name"/>

	<h2 class="section-title">
		<xsl:choose>
			<xsl:when test="$entry-type='method'">
				<span class="name">
					<xsl:if test="not(contains($entry-name, '.')) and not(contains($entry-name, '{')) and $entry-name != 'jQuery'">.</xsl:if>
					<xsl:value-of select="@name"/>
					<xsl:text>(</xsl:text>
					<xsl:if test="signature/argument"><xsl:text> </xsl:text>
						<xsl:variable name="sig-arg-num" select="count(signature[1]/argument)"/>
						<xsl:for-each select="signature[1]/argument">
							<xsl:if test="@optional"> [</xsl:if>
							<xsl:if test="position() &gt; 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="@name"/>
							<xsl:if test="@optional">] </xsl:if>
						</xsl:for-each>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</span>
				<xsl:text> </xsl:text>
				<span class="returns">
					<xsl:if test="@return != ''">
						<xsl:text>Returns: </xsl:text>
						<a class="return" href="http://api.jquery.com/Types/#{@return}">
							<xsl:value-of select="@return"/>
						</a>
					</xsl:if>
				</span>
			</xsl:when>
			<xsl:when test="$entry-type='selector'">
				<span>
					<xsl:value-of select="@name"/>
					<xsl:text> selector</xsl:text>
				</span>
			</xsl:when>
			<xsl:when test="$entry-type='property'">
				<span>
					<xsl:value-of select="@name"/>
				</span>
				<xsl:text> </xsl:text>
				<span class="returns">
					<xsl:if test="@return != ''">
						<xsl:text>Returns: </xsl:text>
						<a class="return" href="http://api.jquery.com/Types/#{@return}">
							<xsl:value-of select="@return"/>
						</a>
					</xsl:if>
				</span>
			</xsl:when>
			<xsl:when test="$entry-type='Widget'">
				<span>
					<xsl:value-of select="@name"/>
					<xsl:text> widget</xsl:text>
				</span>
			</xsl:when>
		</xsl:choose>
	</h2>
</xsl:template>

<xsl:template match="desc">
	<xsl:param name="entry-name"/>
	<xsl:apply-templates select="./node()">
		<xsl:with-param name="entry-name" select="$entry-name"/>
	</xsl:apply-templates>
</xsl:template>
<!-- This makes elements inside <desc> get copied over properly.
There's probably a better way to do this. -->
<xsl:template match="desc/*">
	<xsl:copy-of select="."/>
</xsl:template>
<xsl:template match="placeholder">
	<xsl:param name="entry-name"/>
	<xsl:value-of select="$entry-name"/>
</xsl:template>

<!-- arguments -->
<xsl:template name="arguments">
	<xsl:if test="argument">
		<xsl:text> </xsl:text>
		<ul>
			<xsl:apply-templates select="argument"/>
		</ul>
	</xsl:if>
</xsl:template>
<!-- TODO consider optional arguments -->
<xsl:template match="argument">
	<li>
		<xsl:value-of select="@name"/>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="render-types" />
		<xsl:if test="not(@null)">
			<xsl:if test="desc">
				<xsl:text>, </xsl:text>
				<xsl:copy-of select="desc/node()"/>
			</xsl:if>
			<ul>
				<xsl:apply-templates select="property"/>
			</ul>
		</xsl:if>
	</li>
</xsl:template>
<!-- argument properties -->
<xsl:template match="argument/property">
	<li>
		<xsl:value-of select="@name"/>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="render-types" />
		<xsl:if test="desc">
			<xsl:text>, </xsl:text>
			<xsl:copy-of select="desc/node()"/>
		</xsl:if>
	</li>
</xsl:template>

<!-- examples -->
<xsl:template match="example">
	<xsl:param name="entry-index"/>
	<xsl:param name="number-examples"/>

	<div class="entry-example">
		<xsl:attribute name="id">
			<xsl:text>example-</xsl:text>
			<xsl:if test="$entry-index &gt; 1">
				<xsl:value-of select="$entry-index - 1"/>
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:value-of select="position() - 1"/>
		</xsl:attribute>

		<h4>
			<xsl:if test="$number-examples &gt; 1">Example: </xsl:if>
			<span class="desc"><xsl:value-of select="desc"/></span>
		</h4>
		<pre><code data-linenum="true">
			<xsl:choose>
				<xsl:when test="html">
					<xsl:call-template name="example-code"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="code/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</code></pre>

		<xsl:if test="html">
			<h4>Demo:</h4>
			<div class="demo code-demo">
				<xsl:if test="height">
					<xsl:attribute name="data-height">
						<xsl:value-of select="height"/>
					</xsl:attribute>
				</xsl:if>
			</div>
		</xsl:if>
	</div>
</xsl:template>
<xsl:template name="example-code"></xsl:template>

<!--
	Render type(s) for an argument element.
	Type can either be a @type attribute or one or more <type> child elements.
-->
<xsl:template name="render-types">
	<xsl:if test="@type and type">
		<strong>ERROR: Use <i>either</i> @type or type elements</strong>
	</xsl:if>

	<!-- a single type -->
	<xsl:if test="@type">
		<xsl:call-template name="render-type">
			<xsl:with-param name="typename" select="@type" />
		</xsl:call-template>
	</xsl:if>

	<!-- elements. Render each type, comma seperated -->
	<xsl:if test="type">
		<xsl:for-each select="type">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:call-template name="render-type">
				<xsl:with-param name="typename" select="@name" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="render-return-types">
	<xsl:if test="@return and return">
		<strong>ERROR: Use <i>either</i> @return or return element</strong>
	</xsl:if>

	<!-- return attribute -->
	<xsl:if test="@return">
		<xsl:call-template name="render-type">
			<xsl:with-param name="typename" select="@return" />
		</xsl:call-template>
	</xsl:if>

	<!-- a return element -->
	<xsl:if test="return">
		<xsl:for-each select="return">
			<xsl:if test="position() &gt; 1">
				<strong>ERROR: A single return element is expected</strong>
			</xsl:if>
			<xsl:call-template name="render-types" />
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- Render a single type -->
<xsl:template name="render-type">
	<xsl:param name="typename"/>
	<xsl:choose>
	<!--
		If the type is "Function" we special case and write the function signature,
		e.g. function(String)=>String
		- formal arguments are child elements to the current element
		- the return element is optional
	-->
	<xsl:when test="$typename = 'Function'">
		<xsl:text>Function(</xsl:text>
		<xsl:for-each select="argument">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:value-of select="@name" />
			<xsl:text>: </xsl:text>
			<xsl:call-template name="render-types" />
		</xsl:for-each>
		<xsl:text>)</xsl:text>

		<!-- display return type if present -->
		<xsl:if test="return or @return">
			=>
			<xsl:call-template name="render-return-types" />
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
		<!-- not function - just display typename -->
		<a href="http://api.jquery.com/Types#{$typename}"><xsl:value-of select="$typename" /></a>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- escape-string, from xml2json.xsl -->
<xsl:template name="escape-string"><xsl:param name="s"/><xsl:text>"</xsl:text><xsl:call-template name="escape-bs-string"><xsl:with-param name="s" select="$s"/></xsl:call-template><xsl:text>"</xsl:text></xsl:template><xsl:template name="escape-bs-string"><xsl:param name="s"/><xsl:choose><xsl:when test="contains($s,'\')"><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/></xsl:call-template><xsl:call-template name="escape-bs-string"><xsl:with-param name="s" select="substring-after($s,'\')"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="$s"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="escape-quot-string"><xsl:param name="s"/><xsl:choose><xsl:when test="contains($s,'&quot;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/></xsl:call-template><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="substring-after($s,'&quot;')"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="encode-string"><xsl:with-param name="s" select="$s"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="encode-string"><xsl:param name="s"/><xsl:choose><!-- tab --><xsl:when test="contains($s,'&#x9;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/></xsl:call-template></xsl:when><!-- line feed --><xsl:when test="contains($s,'&#xA;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/></xsl:call-template></xsl:when><!-- carriage return --><xsl:when test="contains($s,'&#xD;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise></xsl:choose></xsl:template>

</xsl:stylesheet>
