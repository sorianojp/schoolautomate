<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ReloadPage()
{
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}
</script>
<%@ page language="java" import="utility.*,clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTRCol = "";
	String[] astrSortByName    = {"Student ID","Lastname","Firstname","Course","Major","Year Level"};
	String[] astrSortByVal     = {"id_number","lname","fname","course_name","major_name", "year_level"};
	
	int iSearchResult =0;
	
	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./print_out_list.jsp" />
	<%	return;
	}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Status-Print List","print_list.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Clearances","Clearance Status",request.getRemoteAddr(),
														"print_list.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	ClearanceMain clrMain = new ClearanceMain();
		
		vRetResult = clrMain.searchClearance(dbOP, request);
		if(vRetResult == null && WI.fillTextValue("type_index").length()>0)
			strErrMsg = clrMain.getErrMsg();
		else	
			iSearchResult = clrMain.getSearchCount();
			
%>
<body bgcolor="#D2AE72">
<form name="form_" mehtod ="post" action = "print_list.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          CLEARANCES- PRINT LIST PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td colspan="7"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
</tr>
<tr>
<td width="2%">&nbsp;</td>
<td width="14%">SY/Term: </td>
<td width="83%"><% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> 
			<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			to 
			<%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> 
			<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
			/ 
			<select name="semester">
				<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
				<option value="0" selected>Summer</option>
				<%}else{%>
				<option value="0">Summer</option>
				<%}if(strTemp.compareTo("1") ==0){%>
				<option value="1" selected>1st Sem</option>
				<%}else{%>
				<option value="1">1st Sem</option>
				<%}if(strTemp.compareTo("2") == 0){%>
				<option value="2" selected>2nd Sem</option>
				<%}else{%>
				<option value="2">2nd Sem</option>
				<%}if(strTemp.compareTo("3") == 0){%>
				<option value="3" selected>3rd Sem</option>
				<%}else{%>
				<option value="3">3rd Sem</option>
				<%}%>
			</select>
			<a href = 'javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a><font size="1">Click to refresh the page</font>
	  </td></tr>
<tr>
<td colspan="3" height="10"><hr size="1"></td>
</tr>
<tr>
<td width="2%">&nbsp;</td>
<td width="14%">Clearance Type: </td>
<td width="83%"><%strTemp2 = WI.fillTextValue("type_index");%> 
			<select name="type_index" onChange="ReloadPage();">
				<option value="">Select Clearance Type</option>
				<%=dbOP.loadCombo("CLE_CTYPE_INDEX","CLEARANCE_TYPE"," FROM CLE_TYPE WHERE IS_VALID = 1 AND IS_DEL = 0", strTemp2, false)%> 
	  </select></td>
</tr>
<tr>
	<td colspan="3" height="10"><hr size="1"></td>
</tr>
<tr>
	<td width="2%">&nbsp;</td>
	<td colspan="2">
			Sort by:
			<select name="sort_by1" style="font-size:10px">
			<option value="">N/A</option>
	          <%=clrMain.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2" style="font-size:10px">
			<option value="">N/A</option>
	          <%=clrMain.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by3" style="font-size:10px">
				<option value="">N/A</option>
	          <%=clrMain.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by4" style="font-size:10px">
				<option value="">N/A</option>
	          <%=clrMain.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> 
			</select><br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by1_con" style="font-size:10px">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2_con" style="font-size:10px">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by3_con" style="font-size:10px">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by4_con" style="font-size:10px">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>
	</td>
</tr>
<tr>
	<td colspan="3" height="10"><hr size="1"></td>
</tr>
<tr>
	<td>&nbsp;</td>
		<%strTemp = WI.fillTextValue("showType");%>
	<td colspan="5">Type of List : 
			<%if (WI.fillTextValue("showType").compareTo("0")==0) 
			strTemp = "checked"; else strTemp="";%> 
			<input type="radio" name="showType" value="0" <%=strTemp%>>
			Cleared 
			<%if (WI.fillTextValue("showType").compareTo("1")==0)
			strTemp = "checked"; else strTemp="";%> 
			<input type="radio" name="showType" value="1" <%=strTemp%>>
			Not Cleared 
			<%if (WI.fillTextValue("showType").compareTo("2")==0 || WI.fillTextValue("showType").length()==0)
			strTemp = "checked"; else strTemp="";%> 
			<input type="radio" name="showType" value="2" <%=strTemp%>>
			Both</td>
</tr>
<tr>
	<td colspan="4" height="10">&nbsp;</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td><a href = 'javascript:ReloadPage();'><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
	<td width="1%">&nbsp;</td>

</tr>
</table>
  <%if (vRetResult !=null && vRetResult.size()>0){ %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF
          STUDENTS</div></td>
    </tr>
    <tr>
    	<td width="19%" height="25" colspan="4" class="thinborder"><div align="right">
    	<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/clrMain.defSearchSize;
		if(iSearchResult % clrMain.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>&nbsp;<%}%>
		</div></td>
</tr>
<tr>
      <td width="19%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT
          ID </strong></font></div></td>
      <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="40%" class="thinborder"><div align="center"><strong><font size="1">COURSE-MAJOR</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
    <%for(int i = 0; i<vRetResult.size();i+=8){%>
	<%if (((String)vRetResult.elementAt(i)).compareTo("0")==0)
	strTRCol = " bgcolor='#FFDDDD'";
	else
	strTRCol = " bgcolor='#FFFFFF'";
	%>
	<tr <%=strTRCol%>>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),((String)vRetResult.elementAt(i+5)) + "/","",
	  (String)vRetResult.elementAt(i+5))%></font></td>
      <td class="thinborder"><font size="1"><%if (vRetResult.elementAt(i+7)!=null){%><%=(String)vRetResult.elementAt(i+7)%><%}else{%>N/A<%}%></font></td>
</tr>
    <%}%>
</table>
  <%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td height="10"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
</tr>
 <tr>
       <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
</tr>
</table>
<input type="hidden" name="print_page">
<input type="hidden" name="showCond" value="<%=WI.fillTextValue("showCond")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>