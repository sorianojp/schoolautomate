<%@ page language="java" import="utility.*,health.AUFHealthProgram,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";
		
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.	
%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Dependent</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

</style>
</head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/td.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function SearchDependent(){
		document.form_.search_dependent.value = "1";
		document.form_.submit();
	}
	
	function SetIDToCopy(strStudID) {
		document.form_.id_to_copy.value = strStudID;
	}
	
	function CopyIDNumber() {
		var opnerObj;
		eval('opnerObj=window.opener.document.'+document.form_.opner_info.value);
		opnerObj.value=document.form_.id_to_copy.value;
		
		window.opener.focus();
		window.opener.document.form_.submit();
		self.close();
	}
	
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","search_dependent.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	// allow hp employee only if the user is not a student / parent. 
	strTemp = (String)request.getSession(false).getAttribute("userId");
	if(strTemp == null)
		strErrMsg = "You are already logged out. Please login again.";
	else {
		strTemp = dbOP.mapOneToOther("user_table","id_number","'"+strTemp+"'","AUTH_TYPE_INDEX"," and is_valid = 1 and is_del = 0");
		if(strTemp == null || strTemp.equals("4") || strTemp.equals("6"))//student or parent or not having any access
			strErrMsg = "You are not authorized to view Employee hp page.";		
	}
	if(strErrMsg != null) {
		dbOP.cleanUP();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	AUFHealthProgram hp = new AUFHealthProgram();

	if(WI.fillTextValue("search_dependent").length() > 0){
		vRetResult = hp.searchHealthProgramMembers(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hp.getErrMsg();
		else
			iSearchResult = hp.getSearchCount();
	}
%>
<form action="./search_dependent.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH DEPENDENT PAGE ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Dependent</strong></td>
			<td colspan="2"><strong>Sponsoring Employee</strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="12%">ID Number</td>
			<td width="35%">
				<select name="dep_id_number_con">
          			<%=hp.constructGenericDropList(WI.fillTextValue("dep_id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
				</select>
				<input type="text" name="dep_id_number" value="<%=WI.fillTextValue("dep_id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
			<td width="12%">ID Number</td>
			<td width="38%">
				<select name="emp_id_number_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("emp_id_number_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="emp_id_number" value="<%=WI.fillTextValue("emp_id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Firstname</td>
		  	<td>
				<select name="dep_fname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("dep_fname_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="dep_fname" value="<%=WI.fillTextValue("dep_fname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
		  	<td>Firstname</td>
		  	<td>
				<select name="emp_fname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("emp_fname_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="emp_fname" value="<%=WI.fillTextValue("emp_fname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Middlename</td>
		  	<td>
				<select name="dep_mname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("dep_mname_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="dep_mname" value="<%=WI.fillTextValue("dep_mname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
		  	<td>Middlename</td>
		  	<td>
				<select name="emp_mname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("emp_mname_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="emp_mname" value="<%=WI.fillTextValue("emp_mname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lastname</td>
		  	<td>
				<select name="dep_lname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("dep_lname_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="dep_lname" value="<%=WI.fillTextValue("dep_lname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
		  	<td>Lastname</td>
		  	<td>
				<select name="emp_lname_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("emp_lname_con"),astrDropListEqual,astrDropListValEqual)%>
           		</select>
				<input type="text" name="emp_lname" value="<%=WI.fillTextValue("emp_lname")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  	</tr>
		<tr>
		  	<td height="15" colspan="5">&nbsp;</td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Gender</td>
		  	<td>
				<%
					strTemp = WI.fillTextValue("gender");
				%>
				<select name="gender">
				<%if(strTemp.length() == 0){%>
					<option value="" selected>Select Gender</option>
				<%}else{%>
					<option value="">Select Gender</option>
					
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>Male</option>
				<%}else{%>
					<option value="1">Male</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Female</option>
				<%}else{%>
					<option value="2">Female</option>
				<%}%>
				</select></td>
		  	<td>Relationship</td>
		  	<td>
				<select name="relation_con">
              		<%=hp.constructGenericDropList(WI.fillTextValue("relation_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="relation" value="<%=WI.fillTextValue("relation")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Civil Status </td>
		  	<td colspan="3">
				<%
					strTemp = WI.fillTextValue("civil_status");
				%>
				<select name="civil_status">
				<%if(strTemp.length() == 0){%>
					<option value="" selected>Select Civil Status</option>
				<%}else{%>
					<option value="">Select Civil Status</option>
					
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>Single</option>
				<%}else{%>
					<option value="1">Single</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Married</option>
				<%}else{%>
					<option value="2">Married</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>Widowed/Widower</option>
				<%}else{%>
					<option value="3">Widowed/Widower</option>
					
				<%}if(strTemp.equals("4")){%>
					<option value="4" selected>Separated</option>
				<%}else{%>
					<option value="4">Separated</option>
				<%}%>
				</select></td>
	  	</tr>
		<tr>
	  	  <td height="25">&nbsp;</td>
		  	<td>Validity</td>
	      	<td colspan="3">
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("validity"), "0");
					if(strErrMsg.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
		  		<input type="radio" value="0" name="validity" <%=strTemp%>> Show All
				<%
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" value="1" name="validity" <%=strTemp%>> Show Valid Only
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" value="2" name="validity" <%=strTemp%>> Show Invalid Only
		  </td>
      </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
	  <td width="100%" height="10"><hr size="1"></td>
		</tr>
  </table>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%" align="center">
				<input type="image" src="../../../images/refresh.gif" onClick="SearchDependent();">
		    <font size="1">Click to search dependent.</font></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td><strong><font color="#FF0000">
				NOTE:</font></strong> <font color="#0000FF">To 
				display all dependents, click PROCEED button without specifying any hp 
				parameter. Clicking the check box shows or hides values in report below</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" colspan="3"><div align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
				<font size="1">click to print result</font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong>
				<font color="#FFFFFF">LIST OF DEPENDENTS</font></strong></div></td>
		</tr>
		<tr>
			<td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=hp.getDisplayRange()%>)</b></td>
			<td width="34%">
			<%
				//if more than one page , constuct page count list here.  - 20 default display per page)
				int iPageCount = iSearchResult/hp.defSearchSize;
				if(iSearchResult % hp.defSearchSize > 0) ++iPageCount;
				
				if(iPageCount > 1){%>
				<div align="right">Jump To page:
				<select name="jumpto" onChange="SearchDependent();">
				<%
				strTemp = WI.fillTextValue("jumpto");
				if(strTemp == null || strTemp.trim().length() == 0) 
					strTemp = "0";
				
				for( int i =1; i<= iPageCount; ++i ){
					if(i == Integer.parseInt(strTemp) ){%>
						<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}
				}%>
				</select>
				<%}%>
				</div></td>
		</tr>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" width="16%"><div align="center"><strong><font size="1">DEPENDENT ID</font></strong></div></td>
			<td width="30%"><div align="center"><strong><font size="1">NAME (LNAME,FNAME MI) </font></strong></div></td>
			<td width="34%"><div align="center"><strong><font size="1">SPONSORING EMPLOYEE</font></strong></div></td>
			<td width="15%"><div align="center"><strong><font size="1">RELATIONSHIP</font></strong></div></td>
			<td width="5%"><div align="center"><strong><font size="1">SELECT</font></strong></div></td>
		</tr>
	<%for(int i = 0 ; i < vRetResult.size(); i += 15){%>
		<tr> 
			<td height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td>&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4)%></td>
			<td>&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+6), (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), 4)%>
				(<%=(String)vRetResult.elementAt(i+5)%>)</td>
			<td>&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
			<td><div align="center">
			<%
				if(WI.fillTextValue("copy_dep_id").equals("1"))
					strTemp = (String)vRetResult.elementAt(i + 1);
				else
					strTemp = (String)vRetResult.elementAt(i + 5);
			%>
				<input type="radio" name="radiobutton" value="<%=strTemp%>"  onClick='SetIDToCopy("<%=strTemp%>");'></div></td>
		</tr>
	<%}%>
  	</table>
	
	<table width="100%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td height="25" align="center">
				<a href="javascript:CopyIDNumber();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font color="#0000FF" size="1">Click to copy Employee ID </font></div></td>
		</tr>
	</table>
<%}%>

	<table bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_dependent" value="<%=WI.fillTextValue("search_dependent")%>">
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
	<input type="hidden" name="id_to_copy">
	<input type="hidden" name="copy_dep_id" value="<%=WI.fillTextValue("copy_dep_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
