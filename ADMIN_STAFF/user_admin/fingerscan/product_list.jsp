<html>
<head>
<title>SchoolBliz Products</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css"></link>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
 	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value="1";
	this.SubmitOnce("form_");
}
function PageAction(strAction, strInfoIndex)
{		
	if(strAction == 0) {
		var vProceed = confirm("Confirm Delete?");
		if(vProceed){
    		document.form_.info_index.value = strInfoIndex;	
			document.form_.page_action.value=0;
    		this.SubmitOnce("form_");
		}
		return;
	}
	document.form_.info_index.value = strInfoIndex;	
	document.form_.page_action.value=strAction;
	this.SubmitOnce("form_");

}
function PrintPg() {
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
	document.form_.print_.src = "../../images/blank.gif";
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, search.FSProduct" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
    String strPrepareToEdit=WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	int iAccessLevel = 0;
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
		

	try
	{
		dbOP = new DBOperation();
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
	FSProduct  fsProd = new FSProduct();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(fsProd.operateOnProdReg(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = fsProd.getErrMsg();
		else {
			strErrMsg = "Operation Successful";
			strPrepareToEdit = "0";
		}		
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = fsProd.operateOnProdReg(dbOP,request,3);
		if(vEditInfo == null) 
			strErrMsg = fsProd.getErrMsg();
	} 
	
	vRetResult = fsProd.operateOnProdReg(dbOP,request,4);
%>

<body>
<form action="product_list.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="1" id="myADTable1">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong><font size="2">REGISTERED 
          FINGER SCANNER</font></strong></div></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td height="28" colspan="2"><font size="2" color="#FF0000" ><strong><%=WI.getStrValue(strErrMsg)%></strong></font>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="12%">Product ID:</td>
      <% 
	 if(vEditInfo != null)
	 	strTemp =  (String)vEditInfo.elementAt(0);
	 else
		strTemp = "";
	 %>
      <td width="85%" height="32"> <input type="text" name="productID" value="<%=strTemp%>" class="textbox_noborder" readonly="yes"> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Product Key:</td>
      <% if(vEditInfo!=null)
	  		strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = "";	
	  
	  %>
      <td height="27"> <input type="text" name="productKey" value="<%=strTemp%>"> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="24">Note : To register Fingerscan ID, connect finger scanner 
        to client PC and launch fingerscanner application.</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="32"> <%if(vEditInfo !=null){%>
        <a href="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>')"><img src="../../images/edit.gif" border="0"></a> 
        <a href="./product_list.jsp"><img src="../../images/cancel.gif" border="0"></a>
        <%}%>
		
      </td>
    </tr>
    <tr> 
      <td colspan="3">
 <% if(vRetResult!=null && vRetResult.size()>0){ %><a href="javascript:PrintPg()"><img src="../../images/print.gif" border="0" name="print_"></a>
	  <table width="50%" border="0" cellspacing="0" cellpadding="1" class="thinborder">
          <tr> 
            <td class="thinborder" bgcolor="#66ddFF"><strong><font size="1">Total 
              Product(s):<%=vRetResult.size()/2%></font></strong></td>
            <td colspan="2" bgcolor="#66ddFF" class="thinborder" align="right">Date/Time : <%=WI.getTodaysDateTime()%>&nbsp;</td>
          </tr>
          <tr> 
            <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>PRODUCT 
                ID</strong></font></div></td>
            <td width="43%" class="thinborder"><div align="center"><font size="1"><strong>PRODUCT 
                KEY</strong></font></div></td>
            <td width="24%" class="thinborder"> <div align="center"><font size="1"><strong>ACTION</strong></font></div></td>
          </tr>
          <%for(int i=0;i<vRetResult.size();i+=2){%>
          <tr> 
            <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i)%> </font></td>
            <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
            <td class="thinborder"><div align="center"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">EDIT</a></div></td>
          </tr>
          <%} //for(int i=0;i<vRetResult.size();i+=3)
		  %>
        </table>
<%} //if(vRetResult!=null && vRetResult.size()!=0)
else {%>
	<font size="3" color="#0000FF">Please connect Finger scanner to Client PC and launch product registration application.</font>
<%}%>
		
		</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>