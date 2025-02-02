<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Record Going Out</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function RecordGoingOut(){
		document.form_.record_going_out.value = "1";
		document.form_.submit();
	}
	
	function CancelOperation(){
		location = "record_going_out.jsp?info_index="+document.form_.info_index.value;
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Record Going Out","record_going_out.jsp");
	}
	catch(Exception exp) {
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
															"Visitor Management","Record Going In Out",request.getRemoteAddr(),
															"record_going_out.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	String strInfoIndex = WI.fillTextValue("info_index");
	VisitLog visitLog = new VisitLog();
	Vector vTemp = new Vector();
	Vector vRetResult = visitLog.getVisitorLogInformation(dbOP, request);	
	if(vRetResult == null)
		strErrMsg = visitLog.getErrMsg();
	else{	
		if(WI.fillTextValue("record_going_out").length() > 0){
			if(!visitLog.recordVisitorGoingOut(dbOP, request))
				strErrMsg = visitLog.getErrMsg();
			else
				strErrMsg = "Visitor going out record successfully saved.";
		}
	}
%>

<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="record_going_out.jsp">
<jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="30%" align="center" bgcolor="#99CC99">
				<strong><font size="2" color="#FFFFFF">RECORD VISITOR'S GOING OUT </font></strong></td>
			<td width="40%">&nbsp;</td>
		    <td width="30%" align="center" bgcolor="#99CC99">
				<strong><font size="2" color="#FFFFFF">Date and Time: <%=WI.getTodaysDateTime()%></font></strong></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="98%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
		
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="50%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">					
					<tr>
						<td height="25">&nbsp;</td>
					    <td colspan="4">RF Card Status: 
							<%
								strErrMsg = WI.getStrValue(WI.fillTextValue("rf_status"), "1");
								if(strErrMsg.equals("1"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="radio" name="rf_status" value="1" <%=strTemp%>>OK&nbsp;
							<%
								if(strErrMsg.equals("2"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="radio" name="rf_status" value="2" <%=strTemp%>>Lost&nbsp;
							<%
								if(strErrMsg.equals("3"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="radio" name="rf_status" value="3" <%=strTemp%>>Damaged&nbsp;						</td>
				    </tr>
					<tr>
						<td height="15" width="4%">&nbsp;</td>
					    <td width="16%">&nbsp;</td>
					    <td width="28%">&nbsp;</td>
					    <td width="20%">&nbsp;</td>
					    <td width="32%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td colspan="4"><strong><u>Visitor's Info</u></strong></td>
					</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(9);
							else
								strTemp = "";
						%>
					  	<td colspan="3">Last name: <strong><%=strTemp%></strong></td>
		  	        </tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(7);
							else
								strTemp = "";
						%>
					  	<td colspan="3">First name: <strong><%=strTemp%></strong></td>
		 	        </tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
							else
								strTemp = "";
						%>
					  	<td colspan="3">Middle name: <strong><%=strTemp%></strong></td>
	                </tr>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(10);
							else
								strTemp = "";
						%>
					  	<td colspan="3">IDs Presented: <strong><%=strTemp%>
						<%=WI.getStrValue((String)vRetResult.elementAt(26), "/", "","")%>
						</strong></td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td colspan="3">Visitor's Picture: </td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(20);
							else
								strTemp = "0";
							strTemp = "../../upload_img/visitor/"+strTemp+".jpg";
						%>
					 	<td colspan="3" rowspan="4"><img src="<%=strTemp%>" width="100" height="100" border="1"></td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
						<%
							if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(6);
							else
								strTemp = "";
						%>
				        <td colspan="3">Visitor's RF Card No.: <strong><%=strTemp%></strong></td>
		          	</tr>
					<tr>
					  <td height="25" colspan="2">&nbsp;</td>
					  <td colspan="3">Company Name: <%=WI.getStrValue((String)vRetResult.elementAt(27))%></td>
				  </tr>
					<tr>
					  <td height="25" colspan="2">&nbsp;</td>
					  <td colspan="3">Vehicle Type: <%=WI.getStrValue((String)vRetResult.elementAt(28))%></td>
				  </tr>
					<tr>
					  <td height="25" colspan="2">&nbsp;</td>
					  <td colspan="3">Plate Number: <%=WI.getStrValue((String)vRetResult.elementAt(29))%></td>
				  </tr>
					<tr>
					  	<td height="15" colspan="5">&nbsp;</td>
				  	</tr>
					
				</table>
			</td>
			<td width="50%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">					
					<tr>
						<td height="25" colspan="5">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" width="4%">&nbsp;</td>
						<td width="16%">&nbsp;</td>
						<td width="28%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
						<td width="32%">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4"><strong><u>Visitor's visited:</u></strong></td>
			  	    </tr>
					<%if(vRetResult != null && vRetResult.size() > 0 && ((String)vRetResult.elementAt(31)).equals("1")){%>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4" rowspan="4">
							<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr>
									<td width="70%">
										<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
											<tr>
												<%
													if(vRetResult != null && vRetResult.size() > 0)
														strTemp = (String)vRetResult.elementAt(13);
													else
														strTemp = "";
												%>
												<td height="25" class="thinborder">&nbsp;Last name: <strong><%=strTemp%></strong></td>
											</tr>
											<tr>
												<%
													if(vRetResult != null && vRetResult.size() > 0)
														strTemp = (String)vRetResult.elementAt(11);
													else
														strTemp = "";
												%>
												<td height="25" class="thinborder">&nbsp;First name: <strong><%=strTemp%></strong></td>
											</tr>
											<tr>
												<%
													if(vRetResult != null && vRetResult.size() > 0)
														strTemp = WI.getStrValue((String)vRetResult.elementAt(18), "N/A");
													else
														strTemp = "";
												%>
												<td height="25" class="thinborder">&nbsp;Department/Office: <strong><%=strTemp%></strong></td>
											</tr>
											<tr>
												<%
													if(vRetResult != null && vRetResult.size() > 0)
														strTemp = WI.getStrValue((String)vRetResult.elementAt(16), "N/A");
													else
														strTemp = "";
												%>
												<td height="25" class="thinborder">&nbsp;College: <strong><%=strTemp%></strong></td>
											</tr>
										</table></td>
									<td width="30%">&nbsp;</td>
								</tr>
							</table></td>
			  	    </tr>
					
					<tr>
					  	<td height="25">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
			  	  	</tr>
					<%}else if(vRetResult != null && vRetResult.size() > 0 && ((String)vRetResult.elementAt(31)).equals("2")){%>
					
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4">College: <%=WI.getStrValue((String)vRetResult.elementAt(16),"N/A")%></td>
			  	    </tr>
					
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4">Department: <%=WI.getStrValue((String)vRetResult.elementAt(18))%></td>
			  	    </tr>
					
					
					<%}else{%>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4">Event Name: <%=WI.getStrValue((String)vRetResult.elementAt(30))%></td>
			  	    </tr>
					
					
					<%}%>
					<tr>
					  	<td height="15" colspan="5">&nbsp;</td>
			  	  	</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4"><strong><u>Purpose:</u></strong></td>
			  	    </tr>
					<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4" rowspan="2">
							<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr>
									<td width="70%">
										<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
											<tr>
												<%
													if(vRetResult != null && vRetResult.size() > 0)
														strTemp = (String)vRetResult.elementAt(14);
													else
														strTemp = "";
												%>
												<td height="50" class="thinborder" valign="top">
													<div align="justify" style="height:50"><%=strTemp%></div></td>
											</tr>
										</table></td>
									<td width="30%">&nbsp;</td>
								</tr>
							</table></td>
			  	    </tr>					
					<tr>
					  	<td height="25">&nbsp;</td>
			  	  	</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
			  	  	    <td colspan="4"><strong><u>REMARKS: </u></strong></td>
		  	  	    </tr>
					<tr>
					  	<td>&nbsp;</td>
				  	    <td colspan="4">
							<textarea name="remarks" cols="40" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("remarks")%></textarea></td>
			  	    </tr>
				</table>
			</td>
		</tr>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>		
		<td align="center">
		<%if(iAccessLevel > 1){%>
			<a href="javascript:RecordGoingOut();"><img src="../../images/save.gif" border="0"></a>
				<font size="1">Click to save going-out info.</font>&nbsp;
			<a href="javascript:CancelOperation();"><img src="../../images/cancel.gif" border="0"></a>
				<font size="1">Click to cancel changes.</font>
		<%}else{%>
			Not authorized to save record information.
		<%}%></td>
	</tr>
	</table>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="record_going_out">
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
	<input type="hidden" name="going_out" value="1">
	<input type="hidden" name="total_visitors" value="2">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>