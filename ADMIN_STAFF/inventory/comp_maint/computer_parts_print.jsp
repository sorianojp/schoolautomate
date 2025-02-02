<%@ page language="java" import="utility.*, inventory.InvCPUMaintenance, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ViewDetails(strInfoIndex)
{
	var pgLoc = "./view_property_dtls.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){	
%>
function CopyPropNum(strPropNum)
{	
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strPropNum;
	window.opener.focus();
	<%if(strFormName != null){
		if(strFormName.equals("form_")){
	%>
	window.opener.document.<%=strFormName%>.submit();	
	<%}
	}%>
	self.close();
}
<%}%>
</script>

<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","search_computer_parts.jsp");
	
	Vector vRetResult = null;
	Vector vRows = null;
	Vector vColumns = null;
	Vector vRowCols = null;
	
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iColumn = 0;
	int iRowCols = 0;

	int iSearchResult = 0;

	InvCPUMaintenance invCPU = new InvCPUMaintenance();
	String strOthers = null;
	vRetResult = invCPU.getComputerComponents(dbOP, request);
	if(vRetResult == null)
		strErrMsg = invCPU.getErrMsg();
	else{
		vRows = (Vector) vRetResult.elementAt(0);
		vColumns = (Vector) vRetResult.elementAt(1);
	}
	boolean bolPageBreak = false;
	if (vRows != null) {	
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));	
	
		int iNumRec = 0;//System.out.println(vRows);
		for (;iNumRec < vRows.size();){	   
%>

<body onLoad="javascript:window.print()">
<form name="form_">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborderLEFT"><strong>COMPUTER UNITS LOGGED IN THE SYSTEM </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">		
    <tr> 
			<td width="18%" class="thinborder" align="center"><font size="1"><strong>&nbsp; OFFICE / DEPARTMENT </strong></font></td>
      <td width="8%" class="thinborder" align="center" height="25"><font size="1"><strong>PROPERTY 
        NUMBER</strong></font></td>      
			<%for(iColumn = 0;iColumn < vColumns.size();iColumn+=3){%>
      <td align="center" class="thinborder"><font size="1"><strong><%=(String)vColumns.elementAt(iColumn+2)%></strong></font></td>
			<%}%>
			<td align="center" class="thinborder"><strong>Others</strong></td>
    </tr>
    <%

		for(iCount = 1; iNumRec<vRows.size(); iNumRec+=14, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
			vRowCols = (Vector)vRows.elementAt(i+11);		
 		%>
    <tr> 
			<%
				strTemp = WI.getStrValue((String)vRows.elementAt(i+3),(String)vRows.elementAt(i+2));
			%>
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=(String)vRows.elementAt(i+1)%></font></td>
      <%
			//System.out.println("vColumns " + vColumns);
 				strOthers = "";				
			for(iColumn = 0; iColumn < vColumns.size(); iColumn+=3){			 			
				strTemp = "";
				for(iRowCols = 0; iRowCols < vRowCols.size();iRowCols+=8){
					if(((String)vRowCols.elementAt(iRowCols+7)).equals("0"))
						continue;
					
				  if((vRowCols.elementAt(iRowCols+6)).equals(vColumns.elementAt(iColumn+1))){
						strTemp = (String)vRowCols.elementAt(iRowCols+5);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
						vRowCols.remove(iRowCols);
					}
				 }
			%>
			<td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>									
			<%}%>
			<%
 			for(iRowCols = 0; iRowCols < vRowCols.size();iRowCols+=8){  			
					if(strOthers.length() == 0)
						strOthers = (String)vRowCols.elementAt(iRowCols+5);
					else
						strOthers += ", " + (String)vRowCols.elementAt(iRowCols+5);
			}
			%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue(strOthers)%></td>
    </tr>
    <%}%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRows.size()
} //end end upper most if (vRows !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
