<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Project Search</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function SearchTeams(){
		document.form_.search_teams.value = "1";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./search_main.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./team_search_print.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","team_search.jsp");
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
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = null;
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	if(WI.fillTextValue("search_teams").length() > 0){
		vRetResult = billTsu.searchTeams(dbOP, request);
		if(vRetResult == null)
			strErrMsg = billTsu.getErrMsg();
		else
			iSearchResult = billTsu.getSearchCount();
	}

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./team_search.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH TEAMS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td width="10%" align="right">
				<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Team Name: </td>
			<td>
				<select name="team_name_con">
					<%=billTsu.constructGenericDropList(WI.fillTextValue("team_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="team_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("team_name")%>"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Member First Name: </td>
			<td>
				<select name="first_name_con">
					<%=billTsu.constructGenericDropList(WI.fillTextValue("first_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="first_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("first_name")%>"></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Member Middle Name: </td>
			<td>
				<select name="middle_name_con">
					<%=billTsu.constructGenericDropList(WI.fillTextValue("middle_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="middle_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("middle_name")%>"></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Member Last Name: </td>
			<td>
				<select name="last_name_con">
					<%=billTsu.constructGenericDropList(WI.fillTextValue("last_name_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
				<input type="text" name="last_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("last_name")%>"></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:SearchTeams()"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search teams.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="right">
				<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" /></a>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULTS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="2">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(billTsu.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="1"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/billTsu.defSearchSize;		
				if(iSearchResult % billTsu.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+billTsu.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchTeams();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
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
				<%}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
		    <td width="30%" align="center" class="thinborder"><strong>Team Name</strong></td>
		    <td width="65%" align="center" class="thinborder"><strong>Members</strong></td>
		</tr>
	<%	int iCount = 1;
		for(i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=((Vector)vRetResult.elementAt(i+2)).toString()%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_teams" />
	<input type="hidden" name="print_page" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>