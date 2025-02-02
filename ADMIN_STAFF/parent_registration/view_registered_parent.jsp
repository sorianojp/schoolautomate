<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">



function editDetail(strInfoIndex){
	var pgLoc = "./edit_parent_info.jsp?parent_i="+strInfoIndex;			
	var win=window.open(pgLoc,"PrintPg",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function viewDetail(strInfoIndex){
	var pgLoc = "./additional_entry.jsp?info_index="+strInfoIndex;			
	var win=window.open(pgLoc,"PrintPg",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function SearchParent(){
	document.form_.search_.value = "1";
	document.form_.submit();
}


</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Login ID","Lastname","Firstname"};
String[] astrSortByVal     = {"login_id","lname","fname"};

int iSearchResult = 0;
Vector vRetResult = new Vector();
ParentRegistration prSMS = new ParentRegistration();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = prSMS.viewRegisteredParent(dbOP, request);
	if(vRetResult == null)
		strErrMsg = prSMS.getErrMsg();
	else	
		iSearchResult = prSMS.getSearchCount();
}


%>
<form action="./view_registered_parent.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          LIST OF REGISTERED PARENTS ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td align="right"><a href="main.jsp"><img src="../../images/go_back.gif" border="0"></a></td>
	</tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Login ID</td>
      <td colspan="5"><select name="login_id_con">
          <%=prSMS.constructGenericDropList(WI.fillTextValue("login_id_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="login_id" value="<%=WI.fillTextValue("login_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td width="30%"><select name="lname_con">
          <%=prSMS.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Firstname</td>
      <td><select name="fname_con">
        <%=prSMS.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<tr><td colspan="5">&nbsp;</td></tr>
</table>	
	
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Sort by: </td>
		<td width="20%">
			<select name="sort_by1">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="20%">
			<select name="sort_by2">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="40%">
			<select name="sort_by3">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
			</select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td>
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by2_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by3_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
	</tr>
	
	<tr>
		<td height="15" colspan="5"></td>
	</tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td colspan="4">
			<a href="javascript:SearchParent();"><img src="../../images/form_proceed.gif" border="0" /></a>
		</td>
	</tr>
	<tr>
		<td height="15" colspan="5">&nbsp;</td>
	</tr>
</table>
	

 
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF"  class="thinborder">
	<tr><td align="center" height="25" colspan="8"  class="thinborder"><strong>SEARCH RESULT</strong></td></tr>
	<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="3">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(prSMS.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="9"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/prSMS.defSearchSize;		
				if(iSearchResult % prSMS.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+prSMS.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.search_.value='1';document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
	</tr>
	<tr>
		<td class="thinborder" width="10%" height="25"><strong>LOGIN ID</strong></td>
		<td class="thinborder" width="20%" height="25"><strong>PARENT NAME</strong></td>
		<td class="thinborder" width="10%"><strong>CONTACT NO</strong></td>
		<td class="thinborder" width="15%"><strong>EMAIL ADDRESS</strong></td>
		<td class="thinborder" width="21%"><strong>ADDRESS</strong></td>
		<td class="thinborder" width="10%"><strong>RF ID</strong> </td>
		<td class="thinborder" width="5%" align="center"><strong>OPTION</strong></td>
	    <td class="thinborder" width="5%" align="center"><strong>EDIT</strong></td>
	</tr>  
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=10){
	%>
	<tr>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1), "&nbsp;")%></td>
		<td class="thinborder" height="25">
		<%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp;")%></td>
		<td align="center" class="thinborder">
			<a href="javascript:viewDetail('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/view.gif" border="0"></a>		</td>
	    <td align="center" class="thinborder"><a href="javascript:editDetail('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/edit.gif" border="0"></a></td>
	</tr>  
	<%}%>
</table>  
<%}%>


<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#FFFFFF"><td height="25">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="search_" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="old_value" value="<%=WI.fillTextValue("old_value")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>