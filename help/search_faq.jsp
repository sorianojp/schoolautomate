<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userId") == null){%>
	<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
		Please login to access this link.
	</font>
	<%return;
	}
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
<title>Search FAQ</title>
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../jscript/common.js"></script>
<script language="javascript" src="../Ajax/ajax.js"></script>
<script language="javascript">

	function GoHome(){
		location = "./help_main.jsp";
	}

	function SearchCollection() {
		document.form_.searchCollection.value = "1";
		document.form_.submit();
	}
	
	function loadSubModule() {
		var objCOA=document.getElementById("load_sub_module");
		var objModuleInput = document.form_.module[document.form_.module.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../Ajax/AjaxInterface.jsp?methodRef=402&module="+objModuleInput+"&sel_name=sub_module";
		this.processRequest(strURL);
	}

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.faq_title.focus();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;
	String strModuleIndex = null;
	Vector vRetResult = null;
	int i = 0;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HELP-Search FAQ","search_faq.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	String[] astrDropListEqual = {"Any Keywords","All Keywords"};
	String[] astrDropListValEqual = {"any","all"};
	String[] astrSortByName    = {"Module","Sub-Module", "FAQ Title"};
	String[] astrSortByVal     = {"module_name","sub_mod_name","faq_title"};
	
	int iSearchResult = 0;
	
	SystemHelpFile shf = new SystemHelpFile();
	if(WI.fillTextValue("searchCollection").equals("1")){
		vRetResult = shf.searchFAQ(dbOP, request);
		if(vRetResult == null)
			strErrMsg = shf.getErrMsg();
		else	
			iSearchResult = shf.getSearchCount();
	}
%>
<form name="form_" method="post" action="search_faq.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF"><strong>:::: SEARCH FAQ PAGE :::: </strong></font></div></td>
	</tr>
	<tr>
	  <td colspan="3" align="right">
	    <input name="go_back" type="button" onClick="GoHome()" 
			style="font-size:11px; height:20px;border: 1px solid #FF0000;" value="GO BACK"></td>
    </tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td width="16%">Module: </td>
		<% 	
			strTemp = WI.fillTextValue("module"); 
			if(strTemp.length() > 0)
				strModuleIndex = strTemp;
			else
				strModuleIndex = "0";
		%>
		<td>
			<select name="module" onChange="loadSubModule();">
              <option value="">All Module</option>
              <%=dbOP.loadCombo("module_index","module_name"," from module where is_del = 0 order by module_name",strTemp,false)%>
            </select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Sub-Module:</td>
		<td>
		  <label id="load_sub_module">
			<select name="sub_module">
				<option value="">All Sub-Modules</option>
				<%=dbOP.loadCombo("sub_mod_index","sub_mod_name"," from sub_module "+
					" where is_del = 0 and module_index = "+strModuleIndex+
					" order by sub_mod_name", WI.fillTextValue("sub_module"), false)%>
			</select>
		  </label></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>FAQ Title: </td>
		<td>
			<select name="faq_title_con" style="font-size:11px;">
				<%=shf.constructGenericDropList(WI.fillTextValue("faq_title_con"),astrDropListEqual,astrDropListValEqual)%>
			</select>
			<input type="text" name="faq_title" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("faq_title")%>"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>FAQ Detail: </td>
		<td>
			<select name="faq_detail_con" style="font-size:11px;">
				<%=shf.constructGenericDropList(WI.fillTextValue("faq_detail_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>
			<input type="text" name="faq_detail" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("faq_detail")%>">		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Sort by: </td>
		<td>
			<select name="sort_by1" style="font-size:11px;">
				<option value="">N/A</option>
				<%=shf.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by1_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>
			&nbsp;
			<select name="sort_by2" style="font-size:11px;">
				<option value="">N/A</option>
					<%=shf.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by2_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>	
			&nbsp;	
			<select name="sort_by3" style="font-size:11px;">
				<option value="">N/A</option>
					<%=shf.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by3_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>			</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>
		<span class="thinborderRIGHT">
			<input type="submit" name="Submit" value="Search" onClick="SearchCollection();" 
			style="font-size:14px; height:24px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		</span></td>
	</tr>
	
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
</table>

<%if(vRetResult!=null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="2" bgcolor="#B9B292" class="thinborderALL">
				<div align="center"><strong><font color="#FFFFFF">::: SEARCH RESULTS :::</font></strong></div></td>
		</tr>
		<tr bgcolor="#FFFFFF"> 
			<td width="72%" class="thinborderLEFT"><b> Total Results: <%=iSearchResult%> - Showing(<b><%=shf.getDisplayRange()%></b>)</b></td>
			<td width="28%" class="thinborderRIGHT" height="25"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/shf.defSearchSize;		
			if(iSearchResult % shf.defSearchSize > 0) 
				++iPageCount;
			strTemp = " - Showing("+shf.getDisplayRange()+")";
			
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="SearchCollection();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}
				%>
				</select></div>
		<%}%></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">

	<tr bgcolor="#FFFFFF" align="center" style="font-weight:bold">
		<td width="5%" height="28" class="thinborder">&nbsp;</td>
		<td width="24%" class="thinborder">Module</td>
		<td width="24%" class="thinborder">Sub-Module</td>
		<td width="23%" class="thinborder">FAQ Title</td>
		<td width="24%" class="thinborder">FAQ Detail</td>
	</tr>
	<%
		int iCount = 1;
		for(i=0;i<vRetResult.size(); i += 4,iCount++){
	%>	  
	<tr bgcolor="#FFFFFF">
		<td height="25" class="thinborder"><%=iCount%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
	</tr>
	<%}%>
</table>
<%}//end of vRetResult%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	</tr>
	<tr> 
		<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
	</tr>
</table>

	<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>