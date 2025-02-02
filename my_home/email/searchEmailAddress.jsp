<%@ page language="java" import="utility.*,hr.HRNotification,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userId") == null){%>
	<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
		Please login to access this link.
	</font>
	<%return;
	}
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
<title>Search Email Address</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function ReloadPage() {
		document.form_.searchCollection.value = "";
		document.form_.submit();
	}

	function SearchCollection() {
		document.form_.searchCollection.value = "1";
		document.form_.submit();
	}
	
	function checkAllSave() {
		var maxDisp = document.form_.emp_count.value;
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function InsertAddresses(){
		var strAddresses = null;
		var defAddressValue = document.form_.address.value;
		var maxDisp = document.form_.emp_count.value;
		for(var i =1; i< maxDisp; ++i){
			if(eval('document.form_.save_'+i+'.checked')){
				if(strAddresses == null)
					strAddresses = eval('document.form_.save_'+i+'.value');
				else
					strAddresses = strAddresses + ', ' + eval('document.form_.save_'+i+'.value');
			}
		}
		
		if(defAddressValue.length == 0)
			document.form_.address.value = strAddresses;
		else
			document.form_.address.value = defAddressValue + ', ' +strAddresses;
		
		this.CopyEmailAdd();
	}

	function CopyEmailAdd() {
		if(document.form_.opner_info.value.length == 0) {
			alert("Click Insert Addresses only if search page is called clicking Search ICON.");
			return;
		}
		var opnerObj;
		eval('opnerObj=window.opener.document.'+document.form_.opner_info.value);
	
		opnerObj.value=document.form_.address.value;
		window.opener.focus();
		self.close();
	}

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.email_add.focus();">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;
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
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"), "my_home","searchEmailAddress.jsp");
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
	
	String[] astrDropListEqual = {"Any Keywords","All Keywords","Equal to"};
	String[] astrDropListValEqual = {"any","all","equals"};
	String[] astrSortByName    = {"E-mail Address","Last Name"};
	String[] astrSortByVal     = {"email","lname"};
	
	int iSearchResult = 0;
	
	HRNotification hrNot = new HRNotification();
	if(WI.fillTextValue("searchCollection").equals("1")){
		vRetResult = hrNot.searchEmployeeEmailAdd(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hrNot.getErrMsg();
		else	
			iSearchResult = hrNot.getSearchCount();
	}
	else{
		vRetResult = hrNot.searchEmployeeEmailAdd(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hrNot.getErrMsg();
		else
			iSearchResult = hrNot.getSearchCount();
	}
%>
<form name="form_" method="post" action="searchEmailAddress.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF"><strong>:: SEARCH EMAIL ADDRESS PAGE :: </strong></font></div></td>
	</tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td width="16%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		<td width="81%" colspan="2"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>E-mail Address: </td>
		<td colspan="2">
			<select name="email_add_con" style="font-size:11px;">
				<%=hrNot.constructGenericDropList(WI.fillTextValue("email_add_con"),astrDropListEqual,astrDropListValEqual)%>
			</select>
			<input type="text" name="email_add" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("email_add")%>">
		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Last Name:</td>
		<td colspan="2">
			<select name="recepient_con" style="font-size:11px;">
				<%=hrNot.constructGenericDropList(WI.fillTextValue("recepient_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>
			<input type="text" name="recepient" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("recepient")%>">
		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Sort by: </td>
		<td colspan="2">
			<select name="sort_by1" style="font-size:11px;">
				<option value="">N/A</option>
				<%=hrNot.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
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
					<%=hrNot.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
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
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2"><span class="thinborderRIGHT">
			<input type="submit" name="Submit" value="Search" onClick="SearchCollection();" 
			style="font-size:14px; height:24px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		</span></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2" align="right"></td>
	</tr>
</table>

<%if(vRetResult!=null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="2" bgcolor="#B9B292" class="thinborderALL">
				<div align="center"><strong><font color="#FFFFFF">SEARCH RESULTS</font></strong></div></td>
		</tr>
		<tr bgcolor="#FFFFFF"> 
			<td width="72%" class="thinborderLEFT"><b> Total Results: <%=iSearchResult%> - Showing(<b><%=hrNot.getDisplayRange()%></b>)</b></td>
			<td width="28%" class="thinborderRIGHT" height="25"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/hrNot.defSearchSize;		
			if(iSearchResult % hrNot.defSearchSize > 0) 
				++iPageCount;
			strTemp = " - Showing("+hrNot.getDisplayRange()+")";
			
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="SearchCollection();">
				<%
					strTemp = request.getParameter("jumpto");
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
				</select>
		<%}%></div>		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">

	<tr bgcolor="#FFFFFF" align="center" style="font-weight:bold">
		<td width="5%" height="28" class="thinborder">&nbsp;</td>
		<td width="40%" class="thinborder">Name</td>
		<td width="45%" class="thinborder">Email Address </td>
		<td width="10%" align="center" class="thinborder">
			<font size="1"><strong>SELECT ALL<br></strong>
			<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font></td>
	</tr>
	<%
		int iCount = 1;
		for(i=0;i<vRetResult.size(); i += 5,iCount++){
	%>	  
	<tr bgcolor="#FFFFFF">
		<td height="25" class="thinborder"><%=iCount%></td>
		<td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
		<td class="thinborder" align="center" >        
		<input type="checkbox" name="save_<%=iCount%>" value="<%=vRetResult.elementAt(i+4)%>" checked tabindex="-1"></td>
	</tr>
	<%}%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
	<tr bgcolor="#FFFFFF">
		<td height="10" colspan="5">&nbsp;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td height="25">&nbsp;</td>
		<td colspan="2" align="center">
		<input type="button" name="proceed_btn" value=" Insert Addresses " onClick="javascript:InsertAddresses();"
			style="font-size:12px; height:28px;border:1px solid #FF0000;">
		</td>
		<td>&nbsp;</td>
	</tr>
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
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
	<input type="hidden" name="address" value="<%=WI.fillTextValue("address")%>">
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>