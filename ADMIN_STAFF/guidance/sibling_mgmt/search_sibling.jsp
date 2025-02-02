<%@ page language="java" import="utility.*, enrollment.PersonalInfoManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="./search_sibling_print.jsp" />
	<%return;}
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Sibling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function GoBack(){
		location = "./main_sibling.jsp";
	}
	
	function SearchSibling(){
		document.form_.print_pg.value = '';
		document.form_.search_sibling.value = "1";
		document.form_.submit();
	}
	
	function ViewChildren(strParentIndex){
		var pgLoc = "./view_children.jsp?parent_index="+strParentIndex;	
		var win=window.open(pgLoc,"ViewChildren",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	function PrintPage() {
		document.form_.print_pg.value = '1';
		document.form_.search_sibling.value = "1";
		document.form_.submit();
	}
</script>
<body bgcolor="#8C9AAA">
<form name="form_" action="./search_sibling.jsp" method="post">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sibling Management","search_sibling.jsp");
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
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"search_sibling.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	String[] astrDropListEqual = {"Starts With","Ends With", "Contains", "Equals"};
	String[] astrDropListValEqual = {"starts","ends","contains","equals"};
	
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = null;
	PersonalInfoManagement pim = new PersonalInfoManagement();
	
	if(WI.fillTextValue("search_sibling").length() > 0){
		vRetResult = pim.searchSibling(dbOP, request);
		if(vRetResult == null)
			strErrMsg = pim.getErrMsg();
		else
			iSearchResult = pim.getSearchCount();
	}
	
	boolean bolShowName = false;
	
%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F">
			<td height="25" colspan="5" align="center"><font color="#FFFFFF">
				<strong>::::  SEARCH SIBLING ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font color="#FF0000" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">First Name: </td>
	  	    <td colspan="3">
				<select name="first_name_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("first_name_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="first_name" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("first_name")%>"></td>
  	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Middle Name: </td>
	  	    <td colspan="3">
				<select name="middle_name_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("middle_name_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="middle_name" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("middle_name")%>"></td>
  	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Last Name: </td>
	  	    <td colspan="3">
				<select name="last_name_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("last_name_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="last_name" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("last_name")%>"></td>
  	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Student ID: </td>
	  	    <td colspan="3">
				<select name="id_number_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="id_number" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("id_number")%>"></td>
  	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Father's Name: </td>
  	        <td colspan="3">
				<select name="father_name_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("father_name_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="father_name" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("father_name")%>"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Mother's Name: </td>
  	        <td colspan="3">
				<select name="mother_name_con">
       				<%=pim.constructGenericDropList(WI.fillTextValue("mother_name_con"),astrDropListEqual,astrDropListValEqual)%>
      			</select>
        		<input type="text" name="mother_name" class="textbox" size="32" maxlength="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("mother_name")%>"></td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("show_name");
if(strTemp.length() > 0) {
	strTemp     = "checked";
	bolShowName = true;
}
%>			
			<input type="checkbox" name="show_name" value="1" <%=strTemp%>> Show Name of Sibling
			</td>
		    <td width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:SearchSibling()"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search student sibling information.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
<%int iCount = 1;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
			<td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> <font size="1">Print report </font></td>
		</tr>
	</table>
<%if(bolShowName) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#C4D0DD"> 
			<td height="25" colspan="3" align="center" class="thinborder"><strong>::: SEARCH RESULTS ::: </strong></td>
		</tr>
		<tr> 
			<td height="25" colspan="2" class="thinborderBOTTOMLEFT">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=pim.getDisplayRange()%></strong>)</strong></td>
		    <td height="25" class="thinborderBOTTOMLEFT">
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/pim.defSearchSize;		
				if(iSearchResult % pim.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+pim.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchSibling();">
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
						}%>
					</select></div>
				<%}%></td>
		</tr>
	<%
	 String strParentIndex = null;
	while(vRetResult.size() > 0) {
	 	iCount = 1;
		strParentIndex = (String)vRetResult.elementAt(0);%>
		<tr>
			<td height="25" colspan="3" class="thinborder"><strong> &nbsp;&nbsp; Father/Mother Name : <%=vRetResult.elementAt(1)%>/<%=vRetResult.elementAt(2)%></strong><strong></strong></td>
		</tr>
		<%while(vRetResult.size() > 0) {
			if(!vRetResult.elementAt(0).equals(strParentIndex))
				break;
			%>
			<tr>
				<td width="3%" height="25" align="center" class="thinborder"><%=iCount++%></td>
				<td width="30%" class="thinborder"><%=vRetResult.elementAt(6)%></td>
				<td width="67%" class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(3), (String)vRetResult.elementAt(4), (String)vRetResult.elementAt(5), 4)%></td>
			</tr>
		<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}%>
	<%}%>
	</table>
<%}else{%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#C4D0DD"> 
			<td height="25" colspan="5" align="center" class="thinborder"><strong>::: SEARCH RESULTS ::: </strong></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="3">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=pim.getDisplayRange()%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/pim.defSearchSize;		
				if(iSearchResult % pim.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+pim.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchSibling();">
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
						}%>
					</select></div>
				<%}%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="8%"><strong>Count</strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Father's Name</strong></td>
			<td align="center" class="thinborder" width="35%"><strong>Mother's Name</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Children</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>View</strong></td>
		</tr>
	<%
	iCount = 1;
	for(i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewChildren('<%=(String)vRetResult.elementAt(i)%>')">
				<img src="../../../images/view.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
<%}%>

	<input type="hidden" name="search_sibling">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>