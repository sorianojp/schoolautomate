<%@ page language="java" import="utility.*,basicEdu.BasicGEExtn,basicEdu.BasicGE,java.util.Vector,java.util.Date " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student's Directory</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student Directory","stud_directory.jsp");
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
															"Registrar Management","REPORTS",request.getRemoteAddr(),
															"stud_directory_college.jsp");
	
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
	
	boolean bolPageBreak = false;
	boolean bolIsRepair = false;
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = new Vector();

	BasicGE bed =  new BasicGE();
	BasicGEExtn bedExtn = new BasicGEExtn();
	vRetResult = bedExtn.generateStudentDirectory(dbOP, request);
	
	if (vRetResult != null) {
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(18*iMaxRecPerPage);
		if(vRetResult.size()%(18*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>
		
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td height="20" align="center"><font size="+1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center"><%=(SchoolInformation.getAddressLine1(dbOP,false,false)).toUpperCase()%></td>
		</tr>
		<tr>
			<td height="20" align="center"><font size="2"><strong>COLLEGE DEPARTMENT</strong></font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center"><font size="2" color="#FF0000"><strong>STUDENT'S DIRECTORY</strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center"><strong><%=WI.fillTextValue("semester_name")%> 
				A.Y. <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
		
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" width="2%" align="center" class="thinborder">&nbsp;</td>
			<td width="16%" align="center" class="thinborder"><strong><font style="font-size:10px">NAME</font></strong></td>
			<td width="8%" align="center" class="thinborder"><strong><font style="font-size:10px">COURSE</font></strong></td>
			<td width="27%" align="center" class="thinborder"><strong><font style="font-size:10px">CITY/PROVINCIAL ADDRESS</font></strong></td>
			<td width="16%" align="center" class="thinborder"><strong><font style="font-size:10px">PARENTS/GUARDIAN</font></strong></td>
			<td width="14%" align="center" class="thinborder"><strong><font style="font-size:10px">TEL. NO.</font></strong></td>
			<td width="8%" align="center" class="thinborder"><strong><font style="font-size:10px">BIRTHDATE</font></strong></td>
			<td width="4%" align="center" class="thinborder"><strong><font style="font-size:10px">AGE</font></strong></td>
			<td width="5%" align="center" class="thinborder"><strong><font style="font-size:10px">GENDER</font></strong></td>
		</tr>
		<% //System.out.println(vRetResult);
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=18, ++iCount,++iResultCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;
		%>
		<tr>
			<td height="25" class="thinborder"><font style="font-size:10px"><%=iResultCount%></font></td>
			<td class="thinborder"><font style="font-size:10px">
				<%=WebInterface.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i), 4)%></font></td>
			<td class="thinborder" align="center"><font style="font-size:10px">
				<%=(String)vRetResult.elementAt(i+15)%> <%=WI.fillTextValue("grade_level")%></font></td>
			<td class="thinborder">
				<%
					strTemp = "";
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+12));
					if(strTemp.length() > 0 && strErrMsg.length() > 0)
						strTemp += ", ";
					strTemp += strErrMsg;
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+13));
					if(strTemp.length() > 0 && strErrMsg.length() > 0)
						strTemp += ", ";
					strTemp += strErrMsg;
				%>
				<font style="font-size:10px"><%=WI.getStrValue(strTemp, "&nbsp;")%></font></td>
			<td class="thinborder">
				<%				
					
					//strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;");//get father contact num
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+5), "","<br>","");
					if(strErrMsg.startsWith("null"))
						strErrMsg = strErrMsg.substring(4);
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6), "","<br>","");
					if(strTemp.startsWith("null"))
						strTemp = strTemp.substring(4);
					strErrMsg += strTemp;
					
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4), "","<br>","");
					if(strTemp.startsWith("null"))
						strTemp = strTemp.substring(4);
					strErrMsg += strTemp;
					
					//strErrMsg += WI.getStrValue((String)vRetResult.elementAt(i+4), "","","");
					
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7));//get father
					if(strTemp.length() == 0 || strTemp.indexOf("DECEASED") != -1){
						strTemp = WI.getStrValue((String)vRetResult.elementAt(i+9));//if no father info, get mother
						//strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;");//get mother contact num
					}
					if(strTemp.length() == 0 || strTemp.indexOf("DECEASED") != -1){
						strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14), "&nbsp;");//if no mother info also, get guardian
						//strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;");//get guardian contact information
					}
					
					strErrMsg = WI.getStrValue(strErrMsg, "&nbsp;");
					
				%>
				<font style="font-size:10px"><%=strTemp%></font></td>
			<td class="thinborder" align="center"><font style="font-size:10px"><%=strErrMsg%></font></td>
			<td class="thinborder" align="center">
				<%
					if(vRetResult.elementAt(i+3) != null)
						strTemp = ConversionTable.convertMMDDYYYY((Date)vRetResult.elementAt(i+3));
					else
						strTemp = "&nbsp;";
				%>
				<font style="font-size:10px"><%=strTemp%></font></td>
			<td class="thinborder" align="center">
				<%if(vRetResult.elementAt(i+3) != null){%>
					<font style="font-size:10px"><%=bed.convertDOBToAge(((Date)vRetResult.elementAt(i+3)).toString(), WI.getTodaysDate())%></font>
				<%}else{%>&nbsp;<%}%></td>
			<td class="thinborder" align="center"><font style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+16), "&nbsp;")%></font></td>
		</tr>
	<%} //end for loop%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>